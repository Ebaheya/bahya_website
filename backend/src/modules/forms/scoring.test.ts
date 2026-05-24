import {
  ScoringValidationError,
  achievableTotal,
  scoreFormSubmission,
  validateRangesCoverAchievableTotal,
  validateScaleQuestion,
  type ScoreRange,
  type ScoringQuestion,
} from './scoring';

const questions: ScoringQuestion[] = [
  {
    id: 'single',
    type: 'SINGLE_SELECT',
    choices: [
      { id: 'single-0', score: 0 },
      { id: 'single-2', score: 2 },
    ],
  },
  {
    id: 'multi',
    type: 'MULTI_SELECT',
    subscale: 'A',
    choices: [
      { id: 'multi-1', score: 1 },
      { id: 'multi-3', score: 3 },
    ],
  },
  {
    id: 'scale',
    type: 'SCALE',
    subscale: 'D',
    scaleMin: 0,
    scaleMax: 10,
    scaleStep: 1,
  },
];

describe('scoring engine', () => {
  it('scores single-select, multi-select, and scale answers', () => {
    const result = scoreFormSubmission(questions, [
      { questionId: 'single', choiceIds: ['single-2'] },
      { questionId: 'multi', choiceIds: ['multi-1', 'multi-3'] },
      { questionId: 'scale', value: 7 },
    ]);

    expect(result.questionScores).toEqual([
      { questionId: 'single', score: 2, subscale: null },
      { questionId: 'multi', score: 4, subscale: 'A' },
      { questionId: 'scale', score: 7, subscale: 'D' },
    ]);
    expect(result.totalScore).toBe(13);
  });

  it('computes subscale totals independently', () => {
    const result = scoreFormSubmission(questions, [
      { questionId: 'single', choiceIds: ['single-0'] },
      { questionId: 'multi', choiceIds: ['multi-1', 'multi-3'] },
      { questionId: 'scale', value: 5 },
    ]);

    expect(result.subscaleScores).toEqual({ A: 4, D: 5 });
  });

  it('maps whole-form and subscale ranges', () => {
    const ranges: ScoreRange[] = [
      { subscale: null, label: 'Low', minScore: 0, maxScore: 8 },
      { subscale: null, label: 'High', minScore: 9, maxScore: 16 },
      { subscale: 'A', label: 'A-high', minScore: 0, maxScore: 4 },
      { subscale: 'D', label: 'D-high', minScore: 0, maxScore: 10 },
    ];

    const result = scoreFormSubmission(questions, [
      { questionId: 'single', choiceIds: ['single-2'] },
      { questionId: 'multi', choiceIds: ['multi-1', 'multi-3'] },
      { questionId: 'scale', value: 7 },
    ], ranges);

    expect(result.interpretation).toEqual({
      label: 'High',
      subscales: [
        { subscale: 'A', label: 'A-high' },
        { subscale: 'D', label: 'D-high' },
      ],
    });
  });

  it('validates range coverage and rejects gaps and overlaps', () => {
    expect(achievableTotal(questions)).toBe(16);
    expect(() =>
      validateRangesCoverAchievableTotal(questions, [
        { label: 'Low', minScore: 0, maxScore: 5 },
        { label: 'High', minScore: 7, maxScore: 16 },
      ])
    ).toThrow(new ScoringValidationError('FORM_RANGES_GAP', 'Score ranges must cover every achievable score'));

    expect(() =>
      validateRangesCoverAchievableTotal(questions, [
        { label: 'Low', minScore: 0, maxScore: 8 },
        { label: 'High', minScore: 8, maxScore: 16 },
      ])
    ).toThrow(new ScoringValidationError('FORM_RANGES_OVERLAP', 'Score ranges cannot overlap'));
  });

  it('validates scale authoring and submitted step alignment', () => {
    expect(() =>
      validateScaleQuestion({ id: 'bad-scale', type: 'SCALE', scaleMin: 5, scaleMax: 5, scaleStep: 1 })
    ).toThrow(new ScoringValidationError('FORM_SCALE_INVALID_RANGE', 'Scale questions require min < max and step > 0'));

    expect(() =>
      scoreFormSubmission(
        [{ id: 'scale', type: 'SCALE', scaleMin: 0, scaleMax: 10, scaleStep: 2 }],
        [{ questionId: 'scale', value: 3 }]
      )
    ).toThrow(new ScoringValidationError('FORM_SCALE_OUT_OF_RANGE', 'Scale answer is not aligned to step'));
  });
});
