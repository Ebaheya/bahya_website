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

function minQuestionScore(question: ScoringQuestion): number {
  if (question.type === 'SCALE') {
    validateScaleQuestion(question);
    return question.scaleMin ?? 0;
  }

  const scores = (question.choices ?? []).map((choice) => choice.score);
  if (scores.length === 0) return 0;

  if (question.type === 'SINGLE_SELECT') {
    const minSelected = Math.min(...scores);
    return question.required === false ? Math.min(0, minSelected) : minSelected;
  }

  const negativeSum = scores.filter((score) => score < 0).reduce((sum, score) => sum + score, 0);
  if (negativeSum < 0) return negativeSum;

  const minSelected = Math.min(...scores);
  return question.required === false ? Math.min(0, minSelected) : minSelected;
}

function maxQuestionScore(question: ScoringQuestion): number {
  if (question.type === 'SCALE') {
    validateScaleQuestion(question);
    return question.scaleMax ?? 0;
  }

  const scores = (question.choices ?? []).map((choice) => choice.score);
  if (scores.length === 0) return 0;

  if (question.type === 'SINGLE_SELECT') {
    const maxSelected = Math.max(...scores);
    return question.required === false ? Math.max(0, maxSelected) : maxSelected;
  }

  const positiveSum = scores.filter((score) => score > 0).reduce((sum, score) => sum + score, 0);
  if (positiveSum > 0) return positiveSum;

  const maxSelected = Math.max(...scores);
  return question.required === false ? Math.max(0, maxSelected) : maxSelected;
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
  if (!Number.isInteger(value)) {
    throw new ScoringValidationError('FORM_SCALE_OUT_OF_RANGE', 'Scale answer must be an integer');
  }
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
    !Number.isInteger(question.scaleMin) ||
    !Number.isInteger(question.scaleMax) ||
    !Number.isInteger(question.scaleStep) ||
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

export function achievableMin(questions: ScoringQuestion[], subscale?: string | null): number {
  return questions
    .filter((question) => subscale === undefined || (question.subscale ?? null) === subscale)
    .reduce((total, question) => total + minQuestionScore(question), 0);
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
    const subscale = key === '' ? undefined : key;
    const rangeFloor = achievableMin(questions, subscale);
    const expectedMax = achievableTotal(questions, subscale);
    const sorted = [...groupedRanges].sort((a, b) => a.minScore - b.minScore || a.maxScore - b.maxScore);
    let expectedMin = rangeFloor;
    let previousMax: number | null = null;

    for (const range of sorted) {
      if (previousMax !== null && range.minScore <= previousMax) {
        throw new ScoringValidationError('FORM_RANGES_OVERLAP', 'Score ranges cannot overlap');
      }
      previousMax = range.maxScore;

      if (range.maxScore < rangeFloor) continue;
      if (range.minScore > expectedMax) break;

      if (range.minScore > expectedMin) {
        throw new ScoringValidationError('FORM_RANGES_GAP', 'Score ranges must cover every achievable score');
      }
      expectedMin = Math.max(expectedMin, range.maxScore + 1);
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
      const uniqueChoiceIds = question.type === 'MULTI_SELECT' ? [...new Set(selectedChoiceIds)] : selectedChoiceIds;
      if (question.type === 'MULTI_SELECT' && question.required !== false && uniqueChoiceIds.length === 0) {
        throw new ScoringValidationError('FORM_MISSING_REQUIRED_ANSWER', 'Multi-select answer is missing');
      }

      const choices = choiceMap(question);
      score = uniqueChoiceIds.reduce(
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
