import { Prisma, type FormAssignmentTarget } from '@prisma/client';
import type { Request } from 'express';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import {
  emitFormAssigned,
  type FormAssignedNotificationInput,
} from '../notifications/notification.service';
import type { PublishFormInput } from './publish.schema';

const assignmentInclude = {
  patient: { select: { id: true, userId: true } },
  assignedTo: { select: { id: true, role: true } },
  formVersion: { select: { id: true, version: true } },
} satisfies Prisma.FormAssignmentInclude;

type VisibleAssignment = {
  id: string;
  patientId: string;
  patientUserId: string;
  target: FormAssignmentTarget;
  assignedToUserId: string | null;
  formName: string;
};

function normalizedPublishTime(value: Date | null | undefined, now: Date): Date | null {
  return value && value.getTime() > now.getTime() ? value : null;
}

function toNotificationInput(assignment: VisibleAssignment): FormAssignedNotificationInput {
  const isVolunteer = assignment.target === 'VOLUNTEER_FOR_PATIENT';
  return {
    assignmentId: assignment.id,
    patientId: assignment.patientId,
    recipientRole: isVolunteer ? 'VOLUNTEER' : 'PATIENT',
    recipientUserId: isVolunteer ? assignment.assignedToUserId! : assignment.patientUserId,
    formName: assignment.formName,
  };
}

async function notifyVisibleAssignments(assignments: VisibleAssignment[]): Promise<void> {
  await Promise.all(
    assignments.map((assignment) => emitFormAssigned(toNotificationInput(assignment)))
  );
}

export async function publishForm(
  templateId: string,
  input: PublishFormInput,
  actorId: string,
  req?: Request,
  now = new Date()
) {
  const publishAt = normalizedPublishTime(input.publishAt, now);
  const status = publishAt ? 'SCHEDULED' : 'PUBLISHED';

  const assignments = await prisma.$transaction(async (tx) => {
    const template = await tx.formTemplate.findUnique({
      where: { id: templateId },
      include: {
        currentVersion: { include: { questions: { select: { id: true } } } },
      },
    });
    if (!template) throw AppError.notFound('Form not found');
    if (
      !template.isActive ||
      !template.currentVersion ||
      template.currentVersion.status !== 'PUBLISHED' ||
      template.currentVersion.questions.length === 0
    ) {
      throw new AppError(409, 'FORM_NOT_PUBLISHABLE', 'Form is not publishable');
    }

    let recipients: Array<{
      patientId: string;
      patientUserId: string;
      assignedToUserId: string | null;
      target: FormAssignmentTarget;
    }>;

    if (input.target === 'ALL_PATIENTS') {
      const patients = await tx.patient.findMany({
        where: { user: { is: { role: 'PATIENT', isActive: true } } },
        select: { id: true, userId: true },
      });
      recipients = patients.map((patient) => ({
        patientId: patient.id,
        patientUserId: patient.userId,
        assignedToUserId: null,
        target: 'ALL_PATIENTS',
      }));
    } else {
      const patient = await tx.patient.findUnique({
        where: { id: input.patientId },
        select: { id: true, userId: true },
      });
      if (!patient) throw AppError.notFound('Patient not found');

      let assignedToUserId: string | null = null;
      if (input.target === 'VOLUNTEER_FOR_PATIENT') {
        const volunteer = await tx.user.findUnique({
          where: { id: input.volunteerId },
          select: { id: true, role: true },
        });
        if (!volunteer || volunteer.role !== 'VOLUNTEER') {
          throw new AppError(400, 'FORM_INVALID_VOLUNTEER', 'Assigned user must be a volunteer');
        }
        assignedToUserId = volunteer.id;
      }

      recipients = [
        {
          patientId: patient.id,
          patientUserId: patient.userId,
          assignedToUserId,
          target: input.target,
        },
      ];
    }

    return Promise.all(
      recipients.map(async (recipient) => {
        const assignment = await tx.formAssignment.create({
          data: {
            templateId: template.id,
            formVersionId: template.currentVersion!.id,
            patientId: recipient.patientId,
            assignedToUserId: recipient.assignedToUserId,
            assignedById: actorId,
            target: recipient.target,
            status,
            publishAt,
          },
          select: { id: true },
        });

        return {
          id: assignment.id,
          patientId: recipient.patientId,
          patientUserId: recipient.patientUserId,
          target: recipient.target,
          assignedToUserId: recipient.assignedToUserId,
          formName: template.name,
        };
      })
    );
  });

  if (status === 'PUBLISHED') {
    await notifyVisibleAssignments(assignments);
  }

  await writeAudit({
    actorId,
    action: 'FORM_PUBLISHED',
    entityType: 'FormTemplate',
    entityId: templateId,
    newValues: {
      target: input.target,
      assignmentsCreated: assignments.length,
      scheduled: status === 'SCHEDULED',
    },
    req,
  });

  return {
    assignmentsCreated: assignments.length,
    assignmentIds: assignments.map((item) => item.id),
  };
}

export async function listAssignments(templateId: string) {
  const template = await prisma.formTemplate.findUnique({
    where: { id: templateId },
    select: { id: true },
  });
  if (!template) throw AppError.notFound('Form not found');

  return prisma.formAssignment.findMany({
    where: { templateId },
    include: assignmentInclude,
    orderBy: { createdAt: 'desc' },
  });
}

export async function cancelAssignment(assignmentId: string) {
  const cancelled = await prisma.formAssignment.updateMany({
    where: { id: assignmentId, status: { in: ['SCHEDULED', 'PUBLISHED'] } },
    data: { status: 'CANCELLED' },
  });
  const assignment = await prisma.formAssignment.findUnique({
    where: { id: assignmentId },
    include: assignmentInclude,
  });
  if (!assignment) throw AppError.notFound('Form assignment not found');
  if (cancelled.count === 1 || assignment.status === 'CANCELLED') return assignment;
  if (assignment.status === 'SUBMITTED' || assignment.status === 'REVIEWED') {
    throw new AppError(
      409,
      'FORM_ASSIGNMENT_FINALIZED',
      'A submitted assignment cannot be cancelled'
    );
  }
  throw new AppError(409, 'FORM_ASSIGNMENT_FINALIZED', 'Assignment cannot be cancelled');
}

export async function runDueAssignmentsSweep(now = new Date()): Promise<number> {
  const dueAssignments = await prisma.formAssignment.findMany({
    where: { status: 'SCHEDULED', publishAt: { lte: now } },
    select: {
      id: true,
      patientId: true,
      assignedToUserId: true,
      target: true,
      patient: { select: { userId: true } },
      template: { select: { name: true } },
    },
  });

  const promoted: VisibleAssignment[] = [];
  for (const assignment of dueAssignments) {
    const claimed = await prisma.formAssignment.updateMany({
      where: { id: assignment.id, status: 'SCHEDULED', publishAt: { lte: now } },
      data: { status: 'PUBLISHED' },
    });
    if (claimed.count !== 1) continue;

    promoted.push({
      id: assignment.id,
      patientId: assignment.patientId,
      patientUserId: assignment.patient.userId,
      target: assignment.target,
      assignedToUserId: assignment.assignedToUserId,
      formName: assignment.template.name,
    });
  }

  await notifyVisibleAssignments(promoted);
  return promoted.length;
}
