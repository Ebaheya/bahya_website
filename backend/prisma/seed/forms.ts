import { PrismaClient } from '@prisma/client';
import type { CreateFormInput } from '../../src/modules/forms/form.schema';
import { DEFAULT_FORMS } from '../../src/modules/forms/seed/defaults';

function nullIfMissing(value: string | null | undefined): string | null {
  return value ?? null;
}

function versionCreateData(form: CreateFormInput) {
  return {
    version: 1,
    status: 'PUBLISHED' as const,
    publishedAt: new Date(),
    questions: {
      create: form.questions.map((question) => ({
        order: question.order,
        text: question.text,
        type: question.type,
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
      })),
    },
    scoreRanges: {
      create: form.scoreRanges.map((range) => ({
        subscale: nullIfMissing(range.subscale),
        label: range.label,
        minScore: range.minScore,
        maxScore: range.maxScore,
        note: nullIfMissing(range.note),
      })),
    },
  };
}

export async function seedDefaultForms(client: PrismaClient): Promise<number> {
  for (const form of DEFAULT_FORMS) {
    await client.$transaction(async (tx) => {
      const template = await tx.formTemplate.upsert({
        where: { key: form.key },
        create: {
          key: form.key,
          name: form.name,
          description: nullIfMissing(form.description),
          category: nullIfMissing(form.category),
          scoringType: form.scoringType,
          interpretationMode: form.interpretationMode,
          isDefault: true,
          isActive: true,
          versions: { create: versionCreateData(form) },
        },
        update: { isDefault: true },
        include: {
          versions: {
            where: { version: 1 },
            select: { id: true },
          },
        },
      });

      let versionId = template.versions[0]?.id;
      if (!versionId) {
        const version = await tx.formVersion.create({
          data: {
            templateId: template.id,
            ...versionCreateData(form),
          },
          select: { id: true },
        });
        versionId = version.id;
      }

      if (!template.currentVersionId) {
        await tx.formTemplate.update({
          where: { id: template.id },
          data: { currentVersionId: versionId },
        });
      }
    });
  }

  return DEFAULT_FORMS.length;
}

async function main(): Promise<void> {
  const client = new PrismaClient();
  try {
    const count = await seedDefaultForms(client);
    console.log(`Seeded ${count} default forms.`);
  } finally {
    await client.$disconnect();
  }
}

if (require.main === module) {
  void main().catch((err: unknown) => {
    console.error('Failed to seed default forms.', err);
    process.exitCode = 1;
  });
}
