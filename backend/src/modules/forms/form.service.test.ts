import { ZodError } from 'zod';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { AppError } from '../../utils/httpError';
import { createFormSchema, type CreateFormInput } from './form.schema';
import * as formService from './form.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    $transaction: jest.fn(),
    formTemplate: {
      findUnique: jest.fn(),
      findMany: jest.fn(),
      count: jest.fn(),
    },
    formVersion: {
      update: jest.fn(),
    },
  },
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: jest.fn(),
}));

const prismaMock = prisma as unknown as {
  $transaction: jest.Mock;
  formTemplate: {
    findUnique: jest.Mock;
    findMany: jest.Mock;
    count: jest.Mock;
  };
  formVersion: {
    update: jest.Mock;
  };
};

const writeAuditMock = writeAudit as jest.Mock;

const validInput: CreateFormInput = createFormSchema.parse({
  key: 'CLINIC_INTAKE',
  name: 'Clinic Intake Distress Check',
  category: 'Distress',
  scoringType: 'SUM',
  interpretationMode: 'RANGE',
  questions: [
    {
      order: 1,
      text: 'How down have you felt?',
      type: 'SINGLE_SELECT',
      choices: [
        { order: 1, label: 'Not at all', score: 0 },
        { order: 2, label: 'Several days', score: 1 },
      ],
    },
    {
      order: 2,
      text: 'Which symptoms apply?',
      type: 'MULTI_SELECT',
      required: false,
      choices: [
        { order: 1, label: 'Fatigue', score: 1 },
        { order: 2, label: 'Insomnia', score: 1 },
      ],
    },
    {
      order: 3,
      text: 'Rate your distress today',
      type: 'SCALE',
      scaleMin: 0,
      scaleMax: 10,
      scaleStep: 1,
    },
  ],
  scoreRanges: [
    { label: 'Normal', minScore: 0, maxScore: 4 },
    { label: 'Moderate', minScore: 5, maxScore: 9 },
    { label: 'Severe', minScore: 10, maxScore: 13 },
  ],
});

describe('form authoring service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('creates a draft form and reads back the current version structure', async () => {
    const actorId = 'doctor-1';
    const createdForm = {
      id: 'form-1',
      key: validInput.key,
      name: validInput.name,
      versions: [{ id: 'version-1' }],
    };
    const persistedForm = {
      id: 'form-1',
      key: validInput.key,
      name: validInput.name,
      currentVersionId: 'version-1',
      currentVersion: {
        id: 'version-1',
        version: 1,
        status: 'DRAFT',
        questions: [
          {
            id: 'question-1',
            order: 1,
            type: 'SINGLE_SELECT',
            choices: [{ id: 'choice-1', order: 1, score: 0 }],
          },
        ],
        scoreRanges: [{ id: 'range-1', minScore: 0, maxScore: 13 }],
      },
    };
    const tx = {
      formTemplate: {
        findUnique: jest.fn().mockResolvedValue(null),
        create: jest.fn().mockResolvedValue(createdForm),
        update: jest.fn().mockResolvedValue(persistedForm),
      },
    };

    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));
    writeAuditMock.mockResolvedValue(undefined);
    prismaMock.formTemplate.findUnique.mockResolvedValue(persistedForm);

    await expect(formService.createForm(validInput, actorId)).resolves.toEqual(persistedForm);
    await expect(formService.getForm('form-1')).resolves.toEqual(persistedForm);

    expect(tx.formTemplate.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          key: validInput.key,
          versions: expect.objectContaining({
            create: expect.objectContaining({
              status: 'DRAFT',
              questions: expect.objectContaining({
                create: expect.arrayContaining([
                  expect.objectContaining({
                    type: 'SINGLE_SELECT',
                    choices: expect.objectContaining({ create: expect.any(Array) }),
                  }),
                  expect.objectContaining({
                    type: 'SCALE',
                    choices: undefined,
                    scaleMin: 0,
                    scaleMax: 10,
                    scaleStep: 1,
                  }),
                ]),
              }),
            }),
          }),
        }),
      })
    );
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId,
        action: 'FORM_CREATED',
        entityType: 'FormTemplate',
        entityId: 'form-1',
      })
    );
  });

  it('returns a 409 conflict for duplicate form keys', async () => {
    const tx = {
      formTemplate: {
        findUnique: jest.fn().mockResolvedValue({ id: 'existing-form' }),
      },
    };
    prismaMock.$transaction.mockImplementation(async (callback) => callback(tx));

    await expect(formService.createForm(validInput, 'doctor-1')).rejects.toMatchObject({
      statusCode: 409,
      code: 'FORM_KEY_EXISTS',
    });
    expect(writeAuditMock).not.toHaveBeenCalled();
  });

  it('rejects invalid choice, scale, and range authoring input', () => {
    const invalidChoice = {
      ...validInput,
      questions: [{ order: 1, text: 'Empty select', type: 'SINGLE_SELECT' }],
      scoreRanges: [],
    };
    const invalidScale = {
      ...validInput,
      questions: [{ order: 1, text: 'Bad scale', type: 'SCALE', scaleMin: 5, scaleMax: 5, scaleStep: 1 }],
      scoreRanges: [],
    };
    const invalidRanges = {
      ...validInput,
      scoreRanges: [
        { label: 'Low', minScore: 0, maxScore: 5 },
        { label: 'High', minScore: 7, maxScore: 13 },
      ],
    };

    expect(() => createFormSchema.parse(invalidChoice)).toThrow(ZodError);
    expect(() => createFormSchema.parse(invalidScale)).toThrow(ZodError);
    expect(() => createFormSchema.parse(invalidRanges)).toThrow(ZodError);

    expect(createFormSchema.safeParse(invalidChoice).error?.issues[0]?.message).toBe('FORM_QUESTION_NO_CHOICES');
    expect(createFormSchema.safeParse(invalidScale).error?.issues[0]?.message).toBe('FORM_SCALE_INVALID_RANGE');
    expect(createFormSchema.safeParse(invalidRanges).error?.issues[0]?.message).toBe('FORM_RANGES_GAP');
  });

  it('rejects publishing a draft version with zero questions', async () => {
    prismaMock.formTemplate.findUnique.mockResolvedValue({
      id: 'form-1',
      currentVersion: {
        id: 'version-1',
        status: 'DRAFT',
        questions: [],
      },
    });

    await expect(formService.publishVersion('form-1')).rejects.toEqual(
      new AppError(400, 'FORM_VERSION_EMPTY', 'Cannot publish a version with zero questions')
    );
    expect(prismaMock.formVersion.update).not.toHaveBeenCalled();
  });
});
