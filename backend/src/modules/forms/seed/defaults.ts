import { createFormSchema, type CreateFormInput } from '../form.schema';

interface SeedChoice {
  order: number;
  label: string;
  score: number;
}

function choices(labels: readonly string[], firstScore = 0): SeedChoice[] {
  return labels.map((label, index) => ({ order: index + 1, label, score: firstScore + index }));
}

function selectQuestion(
  order: number,
  text: string,
  answerChoices: readonly SeedChoice[],
  subscale?: string
) {
  return {
    order,
    text,
    type: 'SINGLE_SELECT' as const,
    required: true,
    ...(subscale ? { subscale } : {}),
    choices: answerChoices.map((choice) => ({ ...choice })),
  };
}

const PHQ_CHOICES = choices([
  'Not at all',
  'Several days',
  'More than half the days',
  'Nearly every day',
]);
const DISTRESS_CHOICES = choices(['Not at all', 'Mild', 'Moderate', 'Severe']);
const PTSD_CHOICES = choices([
  'Not at all',
  'A little bit',
  'Moderately',
  'Quite a bit',
  'Extremely',
]);
const MANUAL_CHOICES: SeedChoice[] = [
  { order: 1, label: 'Not at all', score: 0 },
  { order: 2, label: 'A little', score: 0 },
  { order: 3, label: 'Quite a bit', score: 0 },
  { order: 4, label: 'Very much', score: 0 },
];

const rawDefaults = [
  {
    key: 'PHQ9',
    name: 'Patient Health Questionnaire-9 (PHQ-9)',
    description: 'Nine-item depression symptom screening instrument.',
    category: 'Depression',
    scoringType: 'SUM',
    interpretationMode: 'RANGE',
    questions: [
      'Little interest or pleasure in doing things',
      'Feeling down, depressed, or hopeless',
      'Sleep difficulty or sleeping too much',
      'Feeling tired or having little energy',
      'Poor appetite or overeating',
      'Feeling bad about yourself or feeling like a failure',
      'Trouble concentrating on activities',
      'Moving or speaking unusually slowly, or being unusually restless',
      'Thoughts that you would be better off dead or of hurting yourself',
    ].map((text, index) => selectQuestion(index + 1, text, PHQ_CHOICES)),
    scoreRanges: [
      { label: 'Minimal', minScore: 0, maxScore: 4 },
      { label: 'Mild', minScore: 5, maxScore: 9 },
      { label: 'Moderate', minScore: 10, maxScore: 14 },
      { label: 'Severe', minScore: 15, maxScore: 19 },
      { label: 'Critical', minScore: 20, maxScore: 27 },
    ],
  },
  {
    key: 'PHQ4',
    name: 'Patient Health Questionnaire-4 (PHQ-4)',
    description: 'Four-item anxiety and depression screening instrument.',
    category: 'Distress',
    scoringType: 'SUM',
    interpretationMode: 'RANGE',
    questions: [
      'Feeling nervous, anxious, or on edge',
      'Not being able to stop or control worrying',
      'Little interest or pleasure in doing things',
      'Feeling down, depressed, or hopeless',
    ].map((text, index) => selectQuestion(index + 1, text, PHQ_CHOICES)),
    scoreRanges: [
      { label: 'Normal', minScore: 0, maxScore: 2 },
      { label: 'Mild', minScore: 3, maxScore: 5 },
      { label: 'Moderate', minScore: 6, maxScore: 8 },
      { label: 'Severe', minScore: 9, maxScore: 12 },
    ],
  },
  {
    key: 'DT',
    name: 'Distress Thermometer',
    description: 'Single-item current distress rating.',
    category: 'Distress',
    scoringType: 'SUM',
    interpretationMode: 'RANGE',
    questions: [
      {
        order: 1,
        text: 'Rate your overall distress during the past week',
        type: 'SCALE',
        required: true,
        scaleMin: 0,
        scaleMax: 10,
        scaleStep: 1,
      },
    ],
    scoreRanges: [
      { label: 'Normal / Mild distress', minScore: 0, maxScore: 3 },
      { label: 'Moderate', minScore: 4, maxScore: 6 },
      { label: 'Severe', minScore: 7, maxScore: 10 },
    ],
  },
  {
    key: 'HADS',
    name: 'Hospital Anxiety and Depression Scale (HADS)',
    description: 'Anxiety and depression subscale screening instrument.',
    category: 'Anxiety and Depression',
    scoringType: 'SUM',
    interpretationMode: 'RANGE',
    questions: [
      'Feeling tense or wound up',
      'Difficulty enjoying usual activities',
      'Experiencing a frightened feeling',
      'Difficulty laughing or seeing the funny side',
      'Having worrying thoughts',
      'Feeling cheerful less often',
      'Difficulty relaxing',
      'Feeling slowed down',
      'Experiencing restless or panicky feelings',
      'Reduced interest in personal appearance',
      'Feeling unable to sit at ease',
      'Difficulty looking forward to enjoyable things',
      'Sudden feelings of panic',
      'Difficulty enjoying a book, program, or activity',
    ].map((text, index) =>
      selectQuestion(index + 1, text, DISTRESS_CHOICES, index % 2 === 0 ? 'A' : 'D')
    ),
    scoreRanges: [
      { subscale: 'A', label: 'Normal', minScore: 0, maxScore: 7 },
      { subscale: 'A', label: 'Borderline', minScore: 8, maxScore: 10 },
      { subscale: 'A', label: 'Red-flag referral', minScore: 11, maxScore: 21 },
      { subscale: 'D', label: 'Normal', minScore: 0, maxScore: 7 },
      { subscale: 'D', label: 'Borderline', minScore: 8, maxScore: 10 },
      { subscale: 'D', label: 'Red-flag referral', minScore: 11, maxScore: 21 },
    ],
  },
  {
    key: 'PTSD',
    name: 'Post-Traumatic Stress Disorder Checklist',
    description: 'Twenty-item post-traumatic stress symptom checklist.',
    category: 'Trauma',
    scoringType: 'SUM',
    interpretationMode: 'RANGE',
    questions: [
      'Unwanted memories of the stressful experience',
      'Disturbing dreams about the stressful experience',
      'Feeling as if the stressful experience were happening again',
      'Feeling very upset when reminded of the experience',
      'Physical reactions when reminded of the experience',
      'Avoiding memories, thoughts, or feelings about the experience',
      'Avoiding external reminders of the experience',
      'Trouble remembering important parts of the experience',
      'Strong negative beliefs about yourself or the world',
      'Blaming yourself or someone else for the experience',
      'Strong negative feelings such as fear, anger, or shame',
      'Loss of interest in activities',
      'Feeling distant or cut off from other people',
      'Trouble experiencing positive feelings',
      'Irritable behavior or angry outbursts',
      'Taking too many risks or doing things that could cause harm',
      'Being watchful or on guard',
      'Feeling jumpy or easily startled',
      'Difficulty concentrating',
      'Trouble falling or staying asleep',
    ].map((text, index) => selectQuestion(index + 1, text, PTSD_CHOICES)),
    scoreRanges: [
      { label: 'Minimal to none', minScore: 0, maxScore: 10 },
      { label: 'Mild', minScore: 11, maxScore: 30 },
      { label: 'Moderate', minScore: 31, maxScore: 50 },
      { label: 'Severe', minScore: 51, maxScore: 80 },
    ],
  },
  {
    key: 'QOL',
    name: 'Quality of Life',
    description: 'Initial manual-review quality-of-life questionnaire.',
    category: 'Quality of Life',
    scoringType: 'MANUAL',
    interpretationMode: 'MANUAL',
    questions: [
      'Difficulty completing everyday activities',
      'Limitations in work or household tasks',
      'Pain affecting daily life',
      'Tiredness affecting daily life',
      'Worry or emotional distress',
      'Difficulty with social or family activities',
      'Overall health during the past week',
      'Overall quality of life during the past week',
    ].map((text, index) => selectQuestion(index + 1, text, MANUAL_CHOICES)),
    scoreRanges: [],
  },
  {
    key: 'MACS',
    name: 'Mental Adjustment to Cancer Scale',
    description: 'Initial manual-review coping and adjustment questionnaire.',
    category: 'Adjustment',
    scoringType: 'MANUAL',
    interpretationMode: 'MANUAL',
    questions: [
      'I try to fight the illness actively',
      'I feel unable to influence what happens',
      'I worry repeatedly about the illness returning or worsening',
      'I seek information and ways to manage treatment',
      'I avoid thinking about the illness where possible',
    ].map((text, index) => selectQuestion(index + 1, text, MANUAL_CHOICES)),
    scoreRanges: [],
  },
] as const;

export const DEFAULT_FORMS: readonly CreateFormInput[] = rawDefaults.map((form) =>
  createFormSchema.parse(form)
);
