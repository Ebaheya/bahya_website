import { z } from 'zod';
import { FORM_ERROR } from './form.errors';

const submissionAnswerSchema = z
  .object({
    questionId: z.string().uuid(),
    choiceIds: z.array(z.string().uuid()).optional(),
    value: z.number().int().optional(),
  })
  .strict()
  .superRefine((answer, ctx) => {
    const hasChoices = answer.choiceIds !== undefined;
    const hasValue = answer.value !== undefined;
    if (hasChoices === hasValue) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: FORM_ERROR.ANSWER_SHAPE_INVALID,
      });
    }
  });

export const submitAssignmentSchema = z
  .object({
    answers: z.array(submissionAnswerSchema).min(1),
  })
  .strict()
  .superRefine((input, ctx) => {
    const seen = new Set<string>();
    for (const answer of input.answers) {
      if (seen.has(answer.questionId)) {
        ctx.addIssue({
          code: z.ZodIssueCode.custom,
          message: FORM_ERROR.DUPLICATE_QUESTION_ANSWER,
        });
        return;
      }
      seen.add(answer.questionId);
    }
  });

export type SubmitAssignmentInput = z.infer<typeof submitAssignmentSchema>;
