import {
  ScoringValidationError,
  achievableMin,
  achievableTotal,
  scoreFormSubmission,
  validateRangesCoverAchievableTotal,
  validateQuestionStructure,
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
    expect(achievableMin(questions)).toBe(1);
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

  it('validates ranges against negative achievable scores', () => {
    const negativeQuestions: ScoringQuestion[] = [
      {
        id: 'single-negative',
        type: 'SINGLE_SELECT',
        choices: [
          { id: 'single-negative-2', score: -2 },
          { id: 'single-positive-1', score: 1 },
        ],
      },
      {
        id: 'multi-negative',
        type: 'MULTI_SELECT',
        choices: [
          { id: 'multi-negative-3', score: -3 },
          { id: 'multi-positive-5', score: 5 },
        ],
      },
    ];

    expect(achievableMin(negativeQuestions)).toBe(-5);
    expect(achievableTotal(negativeQuestions)).toBe(6);
    expect(() =>
      validateRangesCoverAchievableTotal(negativeQuestions, [
        { label: 'Below baseline', minScore: -5, maxScore: -1 },
        { label: 'At or above baseline', minScore: 0, maxScore: 6 },
      ])
    ).not.toThrow();
  });

  it('maps negative runtime scores into covered ranges', () => {
    const result = scoreFormSubmission(
      [
        {
          id: 'single-negative',
          type: 'SINGLE_SELECT',
          choices: [
            { id: 'single-negative-2', score: -2 },
            { id: 'single-positive-1', score: 1 },
          ],
        },
        {
          id: 'multi-negative',
          type: 'MULTI_SELECT',
          choices: [
            { id: 'multi-negative-3', score: -3 },
            { id: 'multi-positive-5', score: 5 },
          ],
        },
      ],
      [
        { questionId: 'single-negative', choiceIds: ['single-negative-2'] },
        { questionId: 'multi-negative', choiceIds: ['multi-negative-3'] },
      ],
      [
        { label: 'Below baseline', minScore: -5, maxScore: -1 },
        { label: 'At or above baseline', minScore: 0, maxScore: 6 },
      ]
    );

    expect(result.totalScore).toBe(-5);
    expect(result.interpretation?.label).toBe('Below baseline');
  });

  it('validates ranges for non-zero scale floors', () => {
    const scaleOnly: ScoringQuestion[] = [
      { id: 'scale', type: 'SCALE', scaleMin: 5, scaleMax: 10, scaleStep: 1 },
    ];

    expect(achievableMin(scaleOnly)).toBe(5);
    expect(achievableTotal(scaleOnly)).toBe(10);
    expect(() =>
      validateRangesCoverAchievableTotal(scaleOnly, [{ label: 'Elevated', minScore: 5, maxScore: 10 }])
    ).not.toThrow();
  });

  it('rejects duplicate multi-select choices', () => {
    expect(() =>
      scoreFormSubmission(
        [
          {
            id: 'multi',
            type: 'MULTI_SELECT',
            choices: [{ id: 'choice', score: 2 }],
          },
        ],
        [{ questionId: 'multi', choiceIds: ['choice', 'choice'] }]
      )
    ).toThrow(new ScoringValidationError('FORM_DUPLICATE_CHOICE', 'Multi-select answers cannot repeat choices'));
  });

  it('scores unique multi-select choices once', () => {
    const result = scoreFormSubmission(
      [
        {
          id: 'multi',
          type: 'MULTI_SELECT',
          choices: [{ id: 'choice', score: 2 }],
        },
      ],
      [{ questionId: 'multi', choiceIds: ['choice'] }]
    );

    expect(result.totalScore).toBe(2);
  });

  it('rejects missing required answers and unknown choices', () => {
    expect(() => scoreFormSubmission(questions, [])).toThrow(
      new ScoringValidationError('FORM_MISSING_REQUIRED_ANSWER', 'Required answer is missing')
    );

    expect(() =>
      scoreFormSubmission([questions[0]], [{ questionId: 'single', choiceIds: ['missing-choice'] }])
    ).toThrow(new ScoringValidationError('FORM_INVALID_CHOICE', 'Unknown choice missing-choice for question single'));
  });

  it('rejects invalid question structures and scale values', () => {
    expect(() => validateQuestionStructure({ id: 'empty', type: 'SINGLE_SELECT', choices: [] })).toThrow(
      new ScoringValidationError('FORM_QUESTION_NO_CHOICES', 'Select questions require choices')
    );

    expect(() =>
      scoreFormSubmission(
        [{ id: 'scale', type: 'SCALE', scaleMin: 0, scaleMax: 10, scaleStep: 1 }],
        [{ questionId: 'scale', value: 11 }]
      )
    ).toThrow(new ScoringValidationError('FORM_SCALE_OUT_OF_RANGE', 'Scale answer is outside the allowed range'));

    expect(() =>
      scoreFormSubmission(
        [{ id: 'scale', type: 'SCALE', scaleMin: 0, scaleMax: 10, scaleStep: 1 }],
        [{ questionId: 'scale', value: 1.5 }]
      )
    ).toThrow(new ScoringValidationError('FORM_SCALE_OUT_OF_RANGE', 'Scale answer must be an integer'));
  });
});
