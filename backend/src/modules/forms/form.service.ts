import { Prisma, type FormQuestionType } from '@prisma/client';
import type { Request } from 'express';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import type { CreateFormInput, ListFormsQuery } from './form.schema';

const formVersionInclude = {
  questions: {
    orderBy: { order: 'asc' },
    include: { choices: { orderBy: { order: 'asc' } } },
  },
  scoreRanges: { orderBy: [{ subscale: 'asc' }, { minScore: 'asc' }] },
} satisfies Prisma.FormVersionInclude;

const formInclude = {
  currentVersion: { include: formVersionInclude },
} satisfies Prisma.FormTemplateInclude;

function nullIfMissing(value: string | null | undefined): string | null {
  return value ?? null;
}

function questionCreateData(question: CreateFormInput['questions'][number]) {
  return {
    order: question.order,
    text: question.text,
    type: question.type as FormQuestionType,
    subscale: nullIfMissing(question.subscale),
    required: question.required,
    scaleMin: question.type === 'SCALE' ? question.scaleMin ?? null : null,
    scaleMax: question.type === 'SCALE' ? question.scaleMax ?? null : null,
    scaleStep: question.type === 'SCALE' ? question.scaleStep ?? null : null,
    choices:
      question.type === 'SCALE'
        ? undefined
        : {
            create: (question.choices ?? []).map((choice) => ({
              order: choice.order,
              label: choice.label,
              score: choice.score,
            })),
          },
  };
}

function isUniqueConstraintError(err: unknown): err is Prisma.PrismaClientKnownRequestError {
  return err instanceof Prisma.PrismaClientKnownRequestError && err.code === 'P2002';
}

export async function createForm(input: CreateFormInput, actorId: string, req?: Request) {
  try {
    const form = await prisma.$transaction(async (tx) => {
      const existing = await tx.formTemplate.findUnique({
        where: { key: input.key },
        select: { id: true },
      });
      if (existing) throw new AppError(409, 'FORM_KEY_EXISTS', 'Form key already exists');

      const created = await tx.formTemplate.create({
        data: {
          key: input.key,
          name: input.name,
          description: nullIfMissing(input.description),
          category: nullIfMissing(input.category),
          scoringType: input.scoringType,
          interpretationMode: input.interpretationMode,
          isDefault: false,
          isActive: true,
          createdById: actorId,
          versions: {
            create: {
              version: 1,
              status: 'DRAFT',
              questions: { create: input.questions.map(questionCreateData) },
              scoreRanges: {
                create: input.scoreRanges.map((range) => ({
                  subscale: nullIfMissing(range.subscale),
                  label: range.label,
                  minScore: range.minScore,
                  maxScore: range.maxScore,
                  note: nullIfMissing(range.note),
                })),
              },
            },
          },
        },
        include: { versions: { where: { version: 1 }, select: { id: true } } },
      });

      const currentVersionId = created.versions[0]?.id;
      if (!currentVersionId) throw AppError.internal('Form version was not created');

      return tx.formTemplate.update({
        where: { id: created.id },
        data: { currentVersionId },
        include: formInclude,
      });
    });

    await writeAudit({
      actorId,
      action: 'FORM_CREATED',
      entityType: 'FormTemplate',
      entityId: form.id,
      newValues: { key: form.key, name: form.name },
      req,
    });

    return form;
  } catch (err) {
    if (isUniqueConstraintError(err)) {
      throw new AppError(409, 'FORM_KEY_EXISTS', 'Form key already exists');
    }
    throw err;
  }
}

export async function getForm(id: string) {
  const form = await prisma.formTemplate.findUnique({ where: { id }, include: formInclude });
  if (!form) throw AppError.notFound('Form not found');
  return form;
}

export async function listForms(query: ListFormsQuery) {
  const where: Prisma.FormTemplateWhereInput = {
    ...(query.isActive !== undefined ? { isActive: query.isActive } : {}),
    ...(query.isDefault !== undefined ? { isDefault: query.isDefault } : {}),
    ...(query.category ? { category: query.category } : {}),
    ...(query.q
      ? {
          OR: [
            { key: { contains: query.q, mode: 'insensitive' } },
            { name: { contains: query.q, mode: 'insensitive' } },
            { description: { contains: query.q, mode: 'insensitive' } },
          ],
        }
      : {}),
  };
  const skip = (query.page - 1) * query.pageSize;

  const [data, total] = await Promise.all([
    prisma.formTemplate.findMany({
      where,
      include: formInclude,
      orderBy: { createdAt: 'desc' },
      skip,
      take: query.pageSize,
    }),
    prisma.formTemplate.count({ where }),
  ]);

  return { data, total, page: query.page, pageSize: query.pageSize };
}

export async function publishVersion(id: string) {
  const form = await prisma.formTemplate.findUnique({
    where: { id },
    include: {
      currentVersion: {
        include: { questions: { select: { id: true } } },
      },
    },
  });

  if (!form || !form.currentVersion) throw AppError.notFound('Form not found');
  if (form.currentVersion.status !== 'DRAFT') {
    throw new AppError(409, 'FORM_VERSION_NOT_DRAFT', 'Only draft versions can be published');
  }
  if (form.currentVersion.questions.length === 0) {
    throw new AppError(400, 'FORM_VERSION_EMPTY', 'Cannot publish a version with zero questions');
  }

  await prisma.formVersion.update({
    where: { id: form.currentVersion.id },
    data: { status: 'PUBLISHED', publishedAt: new Date() },
  });

  return getForm(id);
}
