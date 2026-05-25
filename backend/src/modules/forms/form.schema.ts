import { z } from 'zod';
import {
  ScoringValidationError,
  validateQuestionStructure,
  validateRangesCoverAchievableTotal,
  type ScoreRange,
  type ScoringQuestion,
} from './scoring';

const nullableText = z.string().trim().min(1).max(500).nullable().optional();

const answerChoiceSchema = z
  .object({
    order: z.number().int().min(1),
    label: z.string().trim().min(1).max(300),
    score: z
      .number({ required_error: 'FORM_CHOICE_MISSING_SCORE' })
      .int('FORM_CHOICE_MISSING_SCORE'),
  })
  .strict();

const questionSchema = z
  .object({
    order: z.number().int().min(1),
    text: z.string().trim().min(1).max(1000),
    type: z.enum(['SINGLE_SELECT', 'MULTI_SELECT', 'SCALE']),
    subscale: z.string().trim().min(1).max(80).nullable().optional(),
    required: z.boolean().default(true),
    choices: z.array(answerChoiceSchema).optional(),
    scaleMin: z.number().int().nullable().optional(),
    scaleMax: z.number().int().nullable().optional(),
    scaleStep: z.number().int().nullable().optional(),
  })
  .strict();

const scoreRangeSchema = z
  .object({
    subscale: z.string().trim().min(1).max(80).nullable().optional(),
    label: z.string().trim().min(1).max(120),
    minScore: z.number().int(),
    maxScore: z.number().int(),
    note: z.string().trim().min(1).max(500).nullable().optional(),
  })
  .strict();

function scoringQuestionFromInput(question: z.infer<typeof questionSchema>): ScoringQuestion {
  return {
    id: String(question.order),
    type: question.type,
    subscale: question.subscale ?? null,
    required: question.required,
    scaleMin: question.scaleMin ?? null,
    scaleMax: question.scaleMax ?? null,
    scaleStep: question.scaleStep ?? null,
    choices: (question.choices ?? []).map((choice) => ({
      id: String(choice.order),
      score: choice.score,
    })),
  };
}

function addScoringIssue(ctx: z.RefinementCtx, err: unknown): void {
  if (err instanceof ScoringValidationError) {
    ctx.addIssue({ code: z.ZodIssueCode.custom, message: err.code });
    return;
  }
  throw err;
}

export const createFormSchema = z
  .object({
    key: z
      .string()
      .trim()
      .min(2)
      .max(80)
      .regex(/^[A-Z0-9_][A-Z0-9_-]*$/i, 'FORM_KEY_INVALID'),
    name: z.string().trim().min(1).max(200),
    description: nullableText,
    category: z.string().trim().min(1).max(120).nullable().optional(),
    scoringType: z.enum(['SUM', 'MANUAL']).default('SUM'),
    interpretationMode: z.enum(['RANGE', 'MANUAL', 'NONE']).default('RANGE'),
    questions: z.array(questionSchema).default([]),
    scoreRanges: z.array(scoreRangeSchema).default([]),
  })
  .strict()
  .superRefine((input, ctx) => {
    const scoringQuestions = input.questions.map(scoringQuestionFromInput);

    for (const question of scoringQuestions) {
      try {
        validateQuestionStructure(question);
      } catch (err) {
        addScoringIssue(ctx, err);
      }
    }

    if (input.scoreRanges.length > 0) {
      try {
        validateRangesCoverAchievableTotal(
          scoringQuestions,
          input.scoreRanges.map(
            (range): ScoreRange => ({
              subscale: range.subscale ?? null,
              label: range.label,
              minScore: range.minScore,
              maxScore: range.maxScore,
              note: range.note ?? null,
            })
          )
        );
      } catch (err) {
        addScoringIssue(ctx, err);
      }
    }
  });

export const listFormsQuerySchema = z
  .object({
    q: z.string().trim().min(1).optional(),
    isActive: z
      .enum(['true', 'false'])
      .transform((value) => value === 'true')
      .optional(),
    isDefault: z
      .enum(['true', 'false'])
      .transform((value) => value === 'true')
      .optional(),
    category: z.string().trim().min(1).max(120).optional(),
    page: z.coerce.number().int().min(1).default(1),
    pageSize: z.coerce.number().int().min(1).max(100).default(20),
  })
  .strict();

export const formIdParamSchema = z
  .object({
    id: z.string().uuid(),
  })
  .strict();

export const formVersionParamSchema = z
  .object({
    id: z.string().uuid(),
    version: z.coerce.number().int().min(1),
  })
  .strict();

export const setFormStatusSchema = z
  .object({
    isActive: z.boolean(),
  })
  .strict();

export type CreateFormInput = z.infer<typeof createFormSchema>;
export type ListFormsQuery = z.infer<typeof listFormsQuerySchema>;
export type FormIdParam = z.infer<typeof formIdParamSchema>;
export type FormVersionParam = z.infer<typeof formVersionParamSchema>;
export type SetFormStatusInput = z.infer<typeof setFormStatusSchema>;
