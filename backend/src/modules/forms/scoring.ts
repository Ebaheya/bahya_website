export type FormQuestionType = 'SINGLE_SELECT' | 'MULTI_SELECT' | 'SCALE';

export interface ScoringChoice {
  id: string;
  score: number;
}

export interface ScoringQuestion {
  id: string;
  type: FormQuestionType;
  subscale?: string | null;
  required?: boolean;
  choices?: ScoringChoice[];
  scaleMin?: number | null;
  scaleMax?: number | null;
  scaleStep?: number | null;
}

export interface ScoringAnswer {
  questionId: string;
  choiceIds?: string[];
  value?: number;
}

export interface ScoreRange {
  subscale?: string | null;
  label: string;
  minScore: number;
  maxScore: number;
  note?: string | null;
}

export interface QuestionScore {
  questionId: string;
  score: number;
  subscale: string | null;
}

export interface InterpretationResult {
  label: string | null;
  subscales: Array<{ subscale: string; label: string }>;
}

export interface ScoringResult {
  questionScores: QuestionScore[];
  totalScore: number;
  subscaleScores: Record<string, number>;
  interpretation: InterpretationResult | null;
}

export class ScoringValidationError extends Error {
  constructor(public readonly code: string, message: string) {
    super(message);
    this.name = 'ScoringValidationError';
  }
}

function choiceMap(question: ScoringQuestion): Map<string, ScoringChoice> {
  return new Map((question.choices ?? []).map((choice) => [choice.id, choice]));
}

function maxQuestionScore(question: ScoringQuestion): number {
  if (question.type === 'SCALE') {
    validateScaleQuestion(question);
    return question.scaleMax ?? 0;
  }

  const scores = (question.choices ?? []).map((choice) => choice.score);
  if (question.type === 'SINGLE_SELECT') return Math.max(0, ...scores);

  return scores.filter((score) => score > 0).reduce((sum, score) => sum + score, 0);
}

function findAnswer(question: ScoringQuestion, answersByQuestion: Map<string, ScoringAnswer>) {
  const answer = answersByQuestion.get(question.id);
  if (!answer && question.required !== false) {
    throw new ScoringValidationError('FORM_MISSING_REQUIRED_ANSWER', 'Required answer is missing');
  }
  return answer;
}

function assertKnownChoice(question: ScoringQuestion, choiceId: string, choices: Map<string, ScoringChoice>) {
  const choice = choices.get(choiceId);
  if (!choice) {
    throw new ScoringValidationError('FORM_INVALID_CHOICE', `Unknown choice ${choiceId} for question ${question.id}`);
  }
  return choice;
}

function assertStepAligned(question: ScoringQuestion, value: number): void {
  const min = question.scaleMin ?? 0;
  const step = question.scaleStep ?? 1;
  if ((value - min) % step !== 0) {
    throw new ScoringValidationError('FORM_SCALE_OUT_OF_RANGE', 'Scale answer is not aligned to step');
  }
}

export function validateScaleQuestion(question: ScoringQuestion): void {
  if (question.type !== 'SCALE') return;

  if (
    question.scaleMin === null ||
    question.scaleMin === undefined ||
    question.scaleMax === null ||
    question.scaleMax === undefined ||
    question.scaleStep === null ||
    question.scaleStep === undefined ||
    question.scaleMin >= question.scaleMax ||
    question.scaleStep <= 0
  ) {
    throw new ScoringValidationError('FORM_SCALE_INVALID_RANGE', 'Scale questions require min < max and step > 0');
  }
}

export function validateQuestionStructure(question: ScoringQuestion): void {
  if (question.type === 'SCALE') {
    validateScaleQuestion(question);
    if ((question.choices ?? []).length > 0) {
      throw new ScoringValidationError('FORM_SCALE_HAS_CHOICES', 'Scale questions cannot have choices');
    }
    return;
  }

  if ((question.choices ?? []).length === 0) {
    throw new ScoringValidationError('FORM_QUESTION_NO_CHOICES', 'Select questions require choices');
  }
}

export function achievableTotal(questions: ScoringQuestion[], subscale?: string | null): number {
  return questions
    .filter((question) => subscale === undefined || (question.subscale ?? null) === subscale)
    .reduce((total, question) => total + maxQuestionScore(question), 0);
}

export function validateRangesCoverAchievableTotal(
  questions: ScoringQuestion[],
  ranges: ScoreRange[]
): void {
  const groups = new Map<string, ScoreRange[]>();

  for (const range of ranges) {
    if (range.minScore > range.maxScore) {
      throw new ScoringValidationError('FORM_RANGES_INVALID', 'Range minScore cannot exceed maxScore');
    }
    const key = range.subscale ?? '';
    groups.set(key, [...(groups.get(key) ?? []), range]);
  }

  for (const [key, groupedRanges] of groups) {
    const subscale = key === '' ? null : key;
    const expectedMax = achievableTotal(questions, subscale);
    const sorted = [...groupedRanges].sort((a, b) => a.minScore - b.minScore || a.maxScore - b.maxScore);
    let expectedMin = 0;

    for (const range of sorted) {
      if (range.minScore < expectedMin) {
        throw new ScoringValidationError('FORM_RANGES_OVERLAP', 'Score ranges cannot overlap');
      }
      if (range.minScore > expectedMin) {
        throw new ScoringValidationError('FORM_RANGES_GAP', 'Score ranges must cover every achievable score');
      }
      expectedMin = range.maxScore + 1;
    }

    if (expectedMin <= expectedMax) {
      throw new ScoringValidationError('FORM_RANGES_GAP', 'Score ranges must cover every achievable score');
    }
  }
}

export function mapScoreRange(
  score: number,
  ranges: ScoreRange[],
  subscale?: string | null
): ScoreRange | null {
  return (
    ranges.find(
      (range) =>
        (range.subscale ?? null) === (subscale ?? null) &&
        range.minScore <= score &&
        score <= range.maxScore
    ) ?? null
  );
}

export function scoreFormSubmission(
  questions: ScoringQuestion[],
  answers: ScoringAnswer[],
  ranges: ScoreRange[] = []
): ScoringResult {
  questions.forEach(validateQuestionStructure);

  const answersByQuestion = new Map(answers.map((answer) => [answer.questionId, answer]));
  const questionScores: QuestionScore[] = [];
  const subscaleScores: Record<string, number> = {};

  for (const question of questions) {
    const answer = findAnswer(question, answersByQuestion);
    if (!answer) continue;

    let score = 0;
    if (question.type === 'SCALE') {
      if (answer.value === undefined) {
        throw new ScoringValidationError('FORM_MISSING_REQUIRED_ANSWER', 'Scale answer value is missing');
      }
      if (answer.value < (question.scaleMin ?? 0) || answer.value > (question.scaleMax ?? 0)) {
        throw new ScoringValidationError('FORM_SCALE_OUT_OF_RANGE', 'Scale answer is outside the allowed range');
      }
      assertStepAligned(question, answer.value);
      score = answer.value;
    } else {
      const selectedChoiceIds = answer.choiceIds ?? [];
      if (question.type === 'SINGLE_SELECT' && selectedChoiceIds.length !== 1) {
        throw new ScoringValidationError('FORM_INVALID_CHOICE_COUNT', 'Single-select questions require exactly one choice');
      }
      if (question.type === 'MULTI_SELECT' && question.required !== false && selectedChoiceIds.length === 0) {
        throw new ScoringValidationError('FORM_MISSING_REQUIRED_ANSWER', 'Multi-select answer is missing');
      }

      const choices = choiceMap(question);
      score = selectedChoiceIds.reduce(
        (sum, choiceId) => sum + assertKnownChoice(question, choiceId, choices).score,
        0
      );
    }

    const subscale = question.subscale ?? null;
    questionScores.push({ questionId: question.id, score, subscale });
    if (subscale) subscaleScores[subscale] = (subscaleScores[subscale] ?? 0) + score;
  }

  const totalScore = questionScores.reduce((sum, item) => sum + item.score, 0);
  const totalRange = mapScoreRange(totalScore, ranges, null);
  const subscaleRanges = Object.entries(subscaleScores)
    .map(([subscale, score]) => ({ subscale, range: mapScoreRange(score, ranges, subscale) }))
    .filter((item): item is { subscale: string; range: ScoreRange } => item.range !== null)
    .map((item) => ({ subscale: item.subscale, label: item.range.label }));

  return {
    questionScores,
    totalScore,
    subscaleScores,
    interpretation:
      totalRange || subscaleRanges.length > 0
        ? { label: totalRange?.label ?? null, subscales: subscaleRanges }
        : null,
  };
}
