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
    scaleMin: question.type === 'SCALE' ? (question.scaleMin ?? null) : null,
    scaleMax: question.type === 'SCALE' ? (question.scaleMax ?? null) : null,
    scaleStep: question.type === 'SCALE' ? (question.scaleStep ?? null) : null,
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

function scoreRangeCreateData(range: CreateFormInput['scoreRanges'][number]) {
  return {
    subscale: nullIfMissing(range.subscale),
    label: range.label,
    minScore: range.minScore,
    maxScore: range.maxScore,
    note: nullIfMissing(range.note),
  };
}

function versionStructureCreateData(input: CreateFormInput) {
  return {
    questions: { create: input.questions.map(questionCreateData) },
    scoreRanges: { create: input.scoreRanges.map(scoreRangeCreateData) },
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
              ...versionStructureCreateData(input),
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

export async function updateForm(
  id: string,
  input: CreateFormInput,
  actorId: string,
  req?: Request
) {
  try {
    const form = await prisma.$transaction(async (tx) => {
      const existing = await tx.formTemplate.findUnique({
        where: { id },
        include: {
          currentVersion: {
            select: { id: true, version: true, status: true },
          },
        },
      });
      if (!existing || !existing.currentVersion) throw AppError.notFound('Form not found');

      // M2: `key` is the stable identity used by the seed (upsert-by-key) and is
      // denormalized onto Assessment.templateKey, so it must not change on edit.
      if (input.key !== existing.key) {
        throw new AppError(409, 'FORM_KEY_IMMUTABLE', 'Form key cannot be changed');
      }

      const templateData = {
        name: input.name,
        description: nullIfMissing(input.description),
        category: nullIfMissing(input.category),
        scoringType: input.scoringType,
        interpretationMode: input.interpretationMode,
      };

      // C1 + H1: only a DRAFT current version may be edited in place. A DRAFT is
      // never published, so nothing can be pinned to it — publishForm requires a
      // PUBLISHED version, and a submission requires a published assignment. Any
      // PUBLISHED version is immutable: editing clones its structure into version
      // N+1 so already-assigned and already-submitted forms keep the exact
      // structure they were given (spec in-flight-assignment invariant).
      let currentVersionId = existing.currentVersion.id;
      if (existing.currentVersion.status === 'DRAFT') {
        await tx.formQuestion.deleteMany({ where: { versionId: currentVersionId } });
        await tx.formScoreRange.deleteMany({ where: { versionId: currentVersionId } });
        await tx.formVersion.update({
          where: { id: currentVersionId },
          data: versionStructureCreateData(input),
        });
      } else {
        // L1: a published version must satisfy the same >=1 question gate as
        // publishVersion (FR-024).
        if (input.questions.length === 0) {
          throw new AppError(400, 'FORM_VERSION_EMPTY', 'Cannot publish a version with zero questions');
        }
        // M1: number the new version from MAX(version)+1 rather than
        // currentVersion.version+1, so it is correct even if currentVersionId is
        // ever repointed to a non-max version.
        const max = await tx.formVersion.aggregate({
          where: { templateId: id },
          _max: { version: true },
        });
        const version = await tx.formVersion.create({
          data: {
            templateId: id,
            version: (max._max.version ?? 0) + 1,
            status: 'PUBLISHED',
            publishedAt: new Date(),
            ...versionStructureCreateData(input),
          },
          select: { id: true },
        });
        currentVersionId = version.id;
      }

      return tx.formTemplate.update({
        where: { id },
        data: { ...templateData, currentVersionId },
        include: formInclude,
      });
    });

    await writeAudit({
      actorId,
      action: 'FORM_UPDATED',
      entityType: 'FormTemplate',
      entityId: form.id,
      newValues: {
        key: form.key,
        name: form.name,
        currentVersionId: form.currentVersionId,
      },
      req,
    });

    return form;
  } catch (err) {
    if (isUniqueConstraintError(err)) {
      // `key` is immutable on update, so the only unique constraint that can fire
      // is (templateId, version) — a concurrent edit that already created N+1.
      throw new AppError(409, 'FORM_VERSION_CONFLICT', 'Form was modified concurrently; please retry');
    }
    throw err;
  }
}

export async function listVersions(id: string) {
  const form = await prisma.formTemplate.findUnique({ where: { id }, select: { id: true } });
  if (!form) throw AppError.notFound('Form not found');

  return prisma.formVersion.findMany({
    where: { templateId: id },
    include: formVersionInclude,
    orderBy: { version: 'desc' },
  });
}

export async function getVersion(id: string, version: number) {
  const formVersion = await prisma.formVersion.findUnique({
    where: { templateId_version: { templateId: id, version } },
    include: formVersionInclude,
  });
  if (!formVersion) throw AppError.notFound('Form version not found');
  return formVersion;
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
