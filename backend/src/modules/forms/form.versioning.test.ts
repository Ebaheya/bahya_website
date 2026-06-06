import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { createFormSchema, type CreateFormInput } from './form.schema';
import * as formService from './form.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    $transaction: jest.fn(),
    formTemplate: {
      findUnique: jest.fn(),
    },
    formVersion: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
  },
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: jest.fn(),
}));

const prismaMock = prisma as unknown as {
  $transaction: jest.Mock;
  formTemplate: { findUnique: jest.Mock };
  formVersion: { findMany: jest.Mock; findUnique: jest.Mock };
};
const writeAuditMock = writeAudit as jest.Mock;

const updateInput: CreateFormInput = createFormSchema.parse({
  key: 'DISTRESS_SCALE',
  name: 'Updated Distress Scale',
  category: 'Distress',
  scoringType: 'SUM',
  interpretationMode: 'RANGE',
  questions: [
    {
      order: 1,
      text: 'Rate your distress today',
      type: 'SCALE',
      scaleMin: 0,
      scaleMax: 10,
      scaleStep: 1,
    },
  ],
  scoreRanges: [
    { label: 'Low', minScore: 0, maxScore: 4 },
    { label: 'High', minScore: 5, maxScore: 10 },
  ],
});

function storedForm(currentVersionId: string, version: number) {
  return {
    id: 'form-1',
    key: updateInput.key,
    name: updateInput.name,
    currentVersionId,
    currentVersion: {
      id: currentVersionId,
      version,
      questions: [{ id: `question-${version}`, text: updateInput.questions[0].text }],
      scoreRanges: [{ id: `range-${version}`, label: 'Low' }],
    },
  };
}

function updateTx(status: 'DRAFT' | 'PUBLISHED', maxVersion = 1, key = updateInput.key) {
  return {
    formTemplate: {
      findUnique: jest.fn().mockResolvedValue({
        id: 'form-1',
        key,
        currentVersion: {
          id: 'version-1',
          version: 1,
          status,
        },
      }),
      update: jest.fn(),
    },
    formQuestion: {
      deleteMany: jest.fn().mockResolvedValue({ count: 1 }),
    },
    formScoreRange: {
      deleteMany: jest.fn().mockResolvedValue({ count: 2 }),
    },
    formVersion: {
      update: jest.fn(),
      create: jest.fn(),
      aggregate: jest.fn().mockResolvedValue({ _max: { version: maxVersion } }),
    },
  };
}

const emptyInput: CreateFormInput = createFormSchema.parse({
  key: 'DISTRESS_SCALE',
  name: 'Empty form',
  scoringType: 'MANUAL',
  interpretationMode: 'NONE',
  questions: [],
  scoreRanges: [],
});

describe('form versioning', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    writeAuditMock.mockResolvedValue(undefined);
  });

  it('updates a DRAFT current version in place without creating a replacement', async () => {
    const tx = updateTx('DRAFT');
    tx.formTemplate.update.mockResolvedValue(storedForm('version-1', 1));
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    const result = await formService.updateForm('form-1', updateInput, 'doctor-1');

    expect(tx.formQuestion.deleteMany).toHaveBeenCalledWith({ where: { versionId: 'version-1' } });
    expect(tx.formScoreRange.deleteMany).toHaveBeenCalledWith({
      where: { versionId: 'version-1' },
    });
    expect(tx.formVersion.update).toHaveBeenCalledWith(
      expect.objectContaining({ where: { id: 'version-1' } })
    );
    expect(tx.formVersion.create).not.toHaveBeenCalled();
    expect(tx.formTemplate.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ currentVersionId: 'version-1' }),
      })
    );
    expect(result.currentVersion?.version).toBe(1);
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({ action: 'FORM_UPDATED', entityId: 'form-1' })
    );
  });

  it('clones a PUBLISHED version to N+1 without mutating the pinned original', async () => {
    // A PUBLISHED version may already back in-flight assignments / submissions,
    // so editing must NOT delete or rewrite its rows — it clones to version 2.
    const tx = updateTx('PUBLISHED');
    tx.formVersion.create.mockResolvedValue({ id: 'version-2' });
    tx.formTemplate.update.mockResolvedValue(storedForm('version-2', 2));
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    const result = await formService.updateForm('form-1', updateInput, 'doctor-1');

    expect(tx.formVersion.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          templateId: 'form-1',
          version: 2,
          status: 'PUBLISHED',
          publishedAt: expect.any(Date),
        }),
      })
    );
    expect(tx.formQuestion.deleteMany).not.toHaveBeenCalled();
    expect(tx.formScoreRange.deleteMany).not.toHaveBeenCalled();
    expect(tx.formVersion.update).not.toHaveBeenCalled();
    expect(result.currentVersionId).toBe('version-2');
  });

  it('numbers the cloned version from MAX(version)+1, not currentVersion+1', async () => {
    const tx = updateTx('PUBLISHED', 4);
    tx.formVersion.create.mockResolvedValue({ id: 'version-5' });
    tx.formTemplate.update.mockResolvedValue(storedForm('version-5', 5));
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await formService.updateForm('form-1', updateInput, 'doctor-1');

    expect(tx.formVersion.create).toHaveBeenCalledWith(
      expect.objectContaining({ data: expect.objectContaining({ version: 5 }) })
    );
  });

  it('rejects changing the immutable form key', async () => {
    const tx = updateTx('DRAFT');
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(
      formService.updateForm('form-1', { ...updateInput, key: 'RENAMED_KEY' }, 'doctor-1')
    ).rejects.toMatchObject({ statusCode: 409, code: 'FORM_KEY_IMMUTABLE' });
    expect(tx.formVersion.create).not.toHaveBeenCalled();
    expect(tx.formQuestion.deleteMany).not.toHaveBeenCalled();
  });

  it('rejects cloning a published version with zero questions (FR-024)', async () => {
    const tx = updateTx('PUBLISHED');
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(formService.updateForm('form-1', emptyInput, 'doctor-1')).rejects.toMatchObject({
      statusCode: 400,
      code: 'FORM_VERSION_EMPTY',
    });
    expect(tx.formVersion.create).not.toHaveBeenCalled();
  });

  it('returns the structure of a historical version by template and version number', async () => {
    const oldVersion = {
      id: 'version-1',
      templateId: 'form-1',
      version: 1,
      questions: [{ id: 'old-question', text: 'Original wording' }],
      scoreRanges: [{ id: 'old-range', label: 'Original range' }],
    };
    prismaMock.formVersion.findUnique.mockResolvedValue(oldVersion);

    await expect(formService.getVersion('form-1', 1)).resolves.toEqual(oldVersion);
    expect(prismaMock.formVersion.findUnique).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { templateId_version: { templateId: 'form-1', version: 1 } },
      })
    );
  });
});
