import type { PrismaClient } from '@prisma/client';
import { DEFAULT_FORMS } from '../../src/modules/forms/seed/defaults';
import { seedDefaultForms } from './forms';

interface StoredTemplate {
  id: string;
  key: string;
  currentVersionId: string | null;
  scoringType: string;
  interpretationMode: string;
  isDefault: boolean;
  versions: Map<number, string>;
}

interface UpsertArgs {
  where: { key: string };
  create: {
    scoringType: string;
    interpretationMode: string;
    isDefault: boolean;
    versions: { create: { version: number } };
  };
  update: { isDefault: boolean };
}

interface UpdateArgs {
  where: { id: string };
  data: { currentVersionId: string };
}

interface VersionCreateArgs {
  data: { templateId: string; version: number };
}

function createInMemoryClient() {
  const templates = new Map<string, StoredTemplate>();
  const formTemplate = {
    upsert: jest.fn(async ({ where, create, update }: UpsertArgs) => {
      let template = templates.get(where.key);
      if (!template) {
        const versionId = `version-${where.key}-1`;
        template = {
          id: `template-${where.key}`,
          key: where.key,
          currentVersionId: null,
          scoringType: create.scoringType,
          interpretationMode: create.interpretationMode,
          isDefault: create.isDefault,
          versions: new Map([[create.versions.create.version, versionId]]),
        };
        templates.set(where.key, template);
      } else {
        template.isDefault = update.isDefault;
      }

      const v1 = template.versions.get(1);
      return {
        id: template.id,
        currentVersionId: template.currentVersionId,
        versions: v1 ? [{ id: v1 }] : [],
      };
    }),
    update: jest.fn(async ({ where, data }: UpdateArgs) => {
      const template = [...templates.values()].find((item) => item.id === where.id);
      if (!template) throw new Error('Template not found in seed test store');
      template.currentVersionId = data.currentVersionId;
      return template;
    }),
  };
  const formVersion = {
    create: jest.fn(async ({ data }: VersionCreateArgs) => {
      const template = [...templates.values()].find((item) => item.id === data.templateId);
      if (!template) throw new Error('Template not found in seed test store');
      const id = `version-${template.key}-${data.version}`;
      template.versions.set(data.version, id);
      return { id };
    }),
  };
  const tx = { formTemplate, formVersion };
  const client = {
    $transaction: jest.fn(async (callback: (value: typeof tx) => Promise<unknown>) => callback(tx)),
  } as unknown as PrismaClient;

  return { client, templates, formTemplate, formVersion };
}

describe('default assessment form definitions', () => {
  it('contains all seven seeded forms with the required automatic and manual structures', () => {
    const byKey = new Map(DEFAULT_FORMS.map((form) => [form.key, form]));

    expect([...byKey.keys()].sort()).toEqual(['DT', 'HADS', 'MACS', 'PHQ4', 'PHQ9', 'PTSD', 'QOL']);
    expect(byKey.get('PHQ9')?.questions).toHaveLength(9);
    expect(byKey.get('PHQ9')?.scoreRanges).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ label: 'Critical', minScore: 20, maxScore: 27 }),
      ])
    );
    expect(byKey.get('PHQ4')?.scoreRanges).toEqual(
      expect.arrayContaining([expect.objectContaining({ minScore: 9, maxScore: 12 })])
    );
    expect(byKey.get('DT')?.questions[0]).toMatchObject({
      type: 'SCALE',
      scaleMin: 0,
      scaleMax: 10,
      scaleStep: 1,
    });
    expect(byKey.get('DT')?.scoreRanges).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ label: 'Severe', minScore: 7, maxScore: 10 }),
      ])
    );

    const hads = byKey.get('HADS');
    expect(hads?.questions.filter((question) => question.subscale === 'A')).toHaveLength(7);
    expect(hads?.questions.filter((question) => question.subscale === 'D')).toHaveLength(7);
    expect(hads?.scoreRanges).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          subscale: 'A',
          label: 'Red-flag referral',
          minScore: 11,
          maxScore: 21,
        }),
        expect.objectContaining({
          subscale: 'D',
          label: 'Red-flag referral',
          minScore: 11,
          maxScore: 21,
        }),
      ])
    );
    expect(byKey.get('PTSD')?.questions).toHaveLength(20);
    expect(byKey.get('PTSD')?.scoreRanges).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ label: 'Severe', minScore: 51, maxScore: 80 }),
      ])
    );

    for (const key of ['QOL', 'MACS']) {
      expect(byKey.get(key)).toMatchObject({
        scoringType: 'MANUAL',
        interpretationMode: 'MANUAL',
        scoreRanges: [],
      });
    }
  });
});

describe('seedDefaultForms', () => {
  it('creates each default once and is idempotent on subsequent runs', async () => {
    const { client, templates, formTemplate, formVersion } = createInMemoryClient();

    await expect(seedDefaultForms(client)).resolves.toBe(7);
    await expect(seedDefaultForms(client)).resolves.toBe(7);

    expect(templates.size).toBe(7);
    for (const template of templates.values()) {
      expect(template.isDefault).toBe(true);
      expect(template.versions.size).toBe(1);
      expect(template.currentVersionId).toBe(`version-${template.key}-1`);
    }
    expect(formTemplate.upsert).toHaveBeenCalledTimes(14);
    expect(formTemplate.update).toHaveBeenCalledTimes(7);
    expect(formVersion.create).not.toHaveBeenCalled();
    expect(templates.get('QOL')).toMatchObject({
      scoringType: 'MANUAL',
      interpretationMode: 'MANUAL',
    });
    expect(templates.get('MACS')).toMatchObject({
      scoringType: 'MANUAL',
      interpretationMode: 'MANUAL',
    });
  });
});
