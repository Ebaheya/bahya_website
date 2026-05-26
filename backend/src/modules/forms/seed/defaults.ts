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

// PHQ-9 / PHQ-4 — تكرار الأعراض، 0–3
const PHQ_CHOICES = choices(['إطلاقاً', 'عدة أيام', 'أكثر من نصف الأيام', 'كل يوم تقريباً']);

// HADS — تكرار مبسّط، 0–3
const HADS_CHOICES = choices(['إطلاقاً', 'أحياناً', 'كثيراً', 'معظم الأوقات']);

// PCL-5 / PTSD — شدة الأعراض، 0–4
const PTSD_CHOICES = choices(['لا يوجد', 'قليلاً', 'بشكل معتدل', 'كثيراً', 'بشكل مفرط']);

// EORTC QLQ-C30 items 1–28 — مقياس رباعي، يبدأ من 1
const QOL_CHOICES = choices(['إطلاقاً', 'قليلاً', 'بما فيه الكفاية', 'كثيراً جداً'], 1);

// Mini-MAC — مدى الانطباق، يبدأ من 1
const MACS_CHOICES = choices(
  ['لا تنطبق علي مطلقاً', 'لا تنطبق علي', 'تنطبق علي', 'تنطبق علي تماماً'],
  1
);

// QLQ-C30 items 1–28 مع وسم المقياس الفرعي
const QOL_ITEMS: ReadonlyArray<{ text: string; subscale: string }> = [
  { text: 'هل لديك صعوبة في بذل مجهود جسدي شاق مثل حمل كيس تسوق ثقيل أو حقيبة؟', subscale: 'PF' },
  { text: 'هل لديك صعوبة في المشي لمسافة طويلة؟', subscale: 'PF' },
  { text: 'هل لديك صعوبة في المشي لمسافة قصيرة خارج البيت؟', subscale: 'PF' },
  { text: 'هل تحتاج إلى البقاء في السرير أو الكرسي خلال اليوم؟', subscale: 'PF' },
  { text: 'هل تحتاج إلى المساعدة في الأكل أو ارتداء الملابس أو الاغتسال أو استخدام المرحاض؟', subscale: 'PF' },
  { text: 'هل كنت محدوداً عند القيام بعملك أو نشاطاتك اليومية الأخرى؟', subscale: 'RF' },
  { text: 'هل كنت محدوداً في ممارسة هواياتك أو نشاطات وقت الفراغ؟', subscale: 'RF' },
  { text: 'هل شعرت بضيق في التنفس؟', subscale: 'DY' },
  { text: 'هل شعرت بأي ألم؟', subscale: 'PA' },
  { text: 'هل كنت بحاجة إلى الراحة؟', subscale: 'FA' },
  { text: 'هل عانيت من مشاكل في النوم (أرق أو نوم متقطع)؟', subscale: 'SL' },
  { text: 'هل شعرت بالضعف؟', subscale: 'FA' },
  { text: 'هل فقدت شهيتك للطعام؟', subscale: 'AP' },
  { text: 'هل شعرت بالغثيان؟', subscale: 'NV' },
  { text: 'هل تقيأت؟', subscale: 'NV' },
  { text: 'هل عانيت من إمساك؟', subscale: 'CO' },
  { text: 'هل كان لديك إسهال؟', subscale: 'DI' },
  { text: 'هل كنت متعباً؟', subscale: 'FA' },
  { text: 'هل أثّر الألم سلباً على نشاطاتك اليومية؟', subscale: 'PA' },
  { text: 'هل كان لديك صعوبة في التركيز على بعض الأمور مثل قراءة الجريدة أو مشاهدة التلفاز؟', subscale: 'CF' },
  { text: 'هل شعرت بالتوتر؟', subscale: 'EF' },
  { text: 'هل شعرت بالقلق؟', subscale: 'EF' },
  { text: 'هل شعرت بالانزعاج؟', subscale: 'EF' },
  { text: 'هل شعرت بالاكتئاب؟', subscale: 'EF' },
  { text: 'هل كانت لديك صعوبة في تذكر الأشياء؟', subscale: 'CF' },
  { text: 'هل أثّرت حالتك الجسدية أو علاجك الطبي سلباً على حياتك العائلية؟', subscale: 'SF' },
  { text: 'هل أثّرت حالتك الجسدية أو علاجك الطبي سلباً على نشاطاتك الاجتماعية؟', subscale: 'SF' },
  { text: 'هل أدّت حالتك الجسدية أو علاجك الطبي إلى مشاكل مالية؟', subscale: 'FI' },
];

function qolQuestions() {
  const selectItems = QOL_ITEMS.map((item, index) =>
    selectQuestion(index + 1, item.text, QOL_CHOICES, item.subscale)
  );
  // البنود 29–30: الصحة العامة وجودة الحياة، مقياس 1–7
  const globalItems = [
    { order: 29, text: 'كيف تُقيّم صحتك عموماً خلال الأسبوع الماضي؟' },
    { order: 30, text: 'كيف تُقيّم جودة حياتك ومستواها عموماً خلال الأسبوع الماضي؟' },
  ].map((item) => ({
    order: item.order,
    text: item.text,
    type: 'SCALE' as const,
    required: true,
    subscale: 'GH',
    scaleMin: 1,
    scaleMax: 7,
    scaleStep: 1,
  }));
  return [...selectItems, ...globalItems];
}

// Mini-MAC بنود 1–29 مع وسم المقياس الفرعي
// HH=يأس/عجز  AP=انشغال قلقي  FS=روح المقاومة  CA=تجنب معرفي  FA=قدرية
const MACS_ITEMS: ReadonlyArray<{ text: string; subscale: string }> = [
  { text: 'في هذه الأيام، أتعامل مع الأمور بشكل عادي ولا أعطيها أكثر مما تستحق', subscale: 'FA' },
  { text: 'ما أُصبت به من مرض هو تحدٍ لي', subscale: 'FS' },
  { text: 'هذا قدري، وأفوض أمري إلى الله', subscale: 'FA' },
  { text: 'أشعر بالاستسلام', subscale: 'HH' },
  { text: 'أشعر بالحسرة والحزن لما أصابني', subscale: 'AP' },
  { text: 'أشعر بحيرة شديدة ولا أعرف كيف أتصرف', subscale: 'HH' },
  { text: 'تملّكني شعور مُدمِّر بعد إصابتي بالسرطان', subscale: 'AP' },
  { text: 'أشكر الله وأقدّر نعمه عليّ', subscale: 'FA' },
  { text: 'عندي قلق من تدهور حالتي أو عودة السرطان مرة أخرى', subscale: 'AP' },
  { text: 'أحاول مقاومة المرض', subscale: 'FS' },
  { text: 'أصرف انتباهي عندما تبدأ الأفكار تجول في خاطري حول المرض', subscale: 'CA' },
  { text: 'لم أعد أستطيع التعامل مع هذا المرض', subscale: 'HH' },
  { text: 'أشعر بخوف وتوجس مما سيحدث لي', subscale: 'AP' },
  { text: 'بسبب المرض، فقدت التفاؤل بالمستقبل', subscale: 'HH' },
  { text: 'أشعر بالعجز عن عمل أي شيء لمساعدة نفسي', subscale: 'HH' },
  { text: 'أشعر بأنها نهاية كل شيء بالنسبة لي', subscale: 'HH' },
  { text: 'عدم التفكير في المرض يساعدني على التعافي', subscale: 'CA' },
  { text: 'لديّ تفانٍ كبير جداً', subscale: 'FS' },
  { text: 'لقد عشت حياة طيبة وما تبقّى منها هو نعمة من الله', subscale: 'FA' },
  { text: 'أشعر بفقدان الأمل في الحياة', subscale: 'HH' },
  { text: 'لا أستطيع مواجهة هذا المرض', subscale: 'HH' },
  { text: 'أنا مستاء من إصابتي بالسرطان', subscale: 'AP' },
  { text: 'قررت التغلب على المرض', subscale: 'FS' },
  {
    text: 'أول ما عرفت أني مصاب بالسرطان، أدركت كم هي الحياة ثمينة، ولذلك أحاول الاستمتاع بها قدر المستطاع',
    subscale: 'FA',
  },
  { text: 'أكاد لا أصدق أن هذا قد حدث لي', subscale: 'AP' },
  { text: 'أبذل جهداً في عدم التفكير في مرضي', subscale: 'CA' },
  { text: 'أتخلص من كل الأفكار السلبية عن السرطان من ذهني', subscale: 'CA' },
  { text: 'أعاني من قلق شديد بسبب هذا المرض', subscale: 'AP' },
  { text: 'أشعر بقليل من الخوف', subscale: 'AP' },
];

const rawDefaults = [
  {
    key: 'PHQ9',
    name: 'Patient Health Questionnaire-9 (PHQ-9)',
    description: 'أداة فحص أعراض الاكتئاب المكونة من تسعة بنود.',
    category: 'Depression',
    scoringType: 'SUM',
    interpretationMode: 'RANGE',
    questions: [
      'قلة الاهتمام أو الشعور بالمتعة في فعل الأشياء',
      'الشعور بالاكتئاب أو اليأس أو فقدان الأمل',
      'صعوبة في النوم أو النوم الزائد',
      'الشعور بالتعب أو قلة النشاط',
      'ضعف الشهية أو الإفراط في الأكل',
      'الشعور بأنك فاشل أو أنك خذلت نفسك أو عائلتك',
      'صعوبة في التركيز على الأشياء مثل قراءة الجريدة أو مشاهدة التلفاز',
      'التحرك أو الكلام ببطء لدرجة لاحظها الآخرون، أو على العكس الأرق والتحرك أكثر من المعتاد',
      'أفكار بأنك أفضل لو كنت ميتاً أو رغبة في إيذاء نفسك بطريقة ما',
    ].map((text, index) => selectQuestion(index + 1, text, PHQ_CHOICES)),
    scoreRanges: [
      { label: 'الحد الأدنى', minScore: 0, maxScore: 4 },
      { label: 'خفيف', minScore: 5, maxScore: 9 },
      { label: 'متوسط', minScore: 10, maxScore: 14 },
      { label: 'شديد', minScore: 15, maxScore: 19 },
      { label: 'حرج', minScore: 20, maxScore: 27 },
    ],
  },
  {
    key: 'PHQ4',
    name: 'Patient Health Questionnaire-4 (PHQ-4)',
    description: 'أداة فحص القلق والاكتئاب المكونة من أربعة بنود.',
    category: 'Distress',
    scoringType: 'SUM',
    interpretationMode: 'RANGE',
    questions: [
      'الشعور بالتوتر أو القلق أو الضيق',
      'عدم القدرة على إيقاف القلق أو السيطرة عليه',
      'قلة الاهتمام أو الشعور بالمتعة في فعل الأشياء',
      'الشعور بالاكتئاب أو اليأس أو فقدان الأمل',
    ].map((text, index) => selectQuestion(index + 1, text, PHQ_CHOICES)),
    scoreRanges: [
      { label: 'طبيعي', minScore: 0, maxScore: 2 },
      { label: 'خفيف', minScore: 3, maxScore: 5 },
      { label: 'متوسط', minScore: 6, maxScore: 8 },
      { label: 'شديد', minScore: 9, maxScore: 12 },
    ],
  },
  {
    key: 'DT',
    name: 'Distress Thermometer',
    description: 'تقييم مستوى الضيق النفسي العام على مقياس من 0 إلى 10.',
    category: 'Distress',
    scoringType: 'SUM',
    interpretationMode: 'RANGE',
    questions: [
      {
        order: 1,
        text: 'قيّم مستوى ضيقك النفسي العام خلال الأسبوع الماضي',
        type: 'SCALE',
        required: true,
        scaleMin: 0,
        scaleMax: 10,
        scaleStep: 1,
      },
    ],
    scoreRanges: [
      { label: 'طبيعي / ضيق خفيف', minScore: 0, maxScore: 3 },
      { label: 'متوسط', minScore: 4, maxScore: 6 },
      { label: 'شديد', minScore: 7, maxScore: 10 },
    ],
  },
  {
    key: 'HADS',
    name: 'Hospital Anxiety and Depression Scale (HADS)',
    description: 'مقياس القلق والاكتئاب في المستشفى — مقياسان فرعيان: القلق (A) والاكتئاب (D).',
    category: 'Anxiety and Depression',
    scoringType: 'SUM',
    interpretationMode: 'RANGE',
    questions: [
      'أشعر بالتوتر أو التقلق',
      'ما أزال أستمتع بنفس الأشياء التي كنت أستمتع بها من قبل',
      'أشعر بالخوف وكأن شيئاً فظيعاً سيحدث لي',
      'أستطيع الضحك ورؤية الجانب المضحك من الأشياء',
      'الأفكار المقلقة تتبادر إلى ذهني',
      'أشعر بالبهجة',
      'أستطيع الجلوس في راحة والشعور بالاسترخاء',
      'أشعر كأنني أتحرك ببطء',
      'أشعر بالرهبة في المعدة',
      'لا أعتني بمظهري',
      'أشعر بعدم القدرة على الاسترخاء',
      'أتطلع إلى المستقبل بتوقع وسرور',
      'أشعر بالذعر المفاجئ',
      'أستمتع بقراءة كتاب أو مشاهدة برنامج تلفزيوني',
    ].map((text, index) =>
      selectQuestion(index + 1, text, HADS_CHOICES, index % 2 === 0 ? 'A' : 'D')
    ),
    scoreRanges: [
      { subscale: 'A', label: 'طبيعي', minScore: 0, maxScore: 7 },
      { subscale: 'A', label: 'حدّي', minScore: 8, maxScore: 10 },
      { subscale: 'A', label: 'إحالة طارئة', minScore: 11, maxScore: 21 },
      { subscale: 'D', label: 'طبيعي', minScore: 0, maxScore: 7 },
      { subscale: 'D', label: 'حدّي', minScore: 8, maxScore: 10 },
      { subscale: 'D', label: 'إحالة طارئة', minScore: 11, maxScore: 21 },
    ],
  },
  {
    key: 'PTSD',
    name: 'Post-Traumatic Stress Disorder Checklist (PCL-5)',
    description: 'قائمة فحص اضطراب ما بعد الصدمة المكونة من عشرين بنداً.',
    category: 'Trauma',
    scoringType: 'SUM',
    interpretationMode: 'RANGE',
    questions: [
      'ذكريات مزعجة أو أفكار أو صور عن التجربة المؤلمة تتبادر إلى ذهنك تلقائياً؟',
      'أحلام مزعجة عن التجربة المؤلمة؟',
      'الشعور فجأة وكأنك تعيش التجربة المؤلمة مرة أخرى كأنها تحدث الآن؟',
      'شعور بضيق شديد عندما يذكرك شيء ما بالتجربة المؤلمة؟',
      'ردود فعل جسدية قوية عندما يذكرك شيء ما بالتجربة المؤلمة (كخفقان القلب أو صعوبة التنفس)؟',
      'تجنب الذكريات أو الأفكار أو المشاعر المرتبطة بالتجربة المؤلمة؟',
      'تجنب الأشياء الخارجية التي تذكرك بالتجربة المؤلمة كالأشخاص أو الأماكن أو الحوادث؟',
      'عدم تذكر أجزاء مهمة من التجربة المؤلمة؟',
      'معتقدات سلبية قوية عن النفس أو الآخرين أو العالم؟',
      'إلقاء اللوم على النفس أو شخص آخر بسبب التجربة المؤلمة أو عواقبها؟',
      'الشعور بمشاعر سلبية قوية مثل الخوف أو الرعب أو الغضب أو الذنب أو الخجل؟',
      'فقدان الاهتمام بالأنشطة التي اعتدت الاستمتاع بها؟',
      'الشعور بالبُعد أو الانعزال عن الآخرين؟',
      'صعوبة الشعور بمشاعر إيجابية كالسعادة أو الحب؟',
      'السلوك الانفعالي أو نوبات الغضب أو التصرفات العدوانية؟',
      'المخاطرة كثيراً أو القيام بأمور قد تسبب لك الأذى؟',
      'الشعور بحالة تأهب أو البقظة الدائمة والحذر المفرط؟',
      'الشعور بالارتياع أو الفزع بسهولة؟',
      'صعوبة في التركيز؟',
      'صعوبة في النوم أو الأرق؟',
    ].map((text, index) => selectQuestion(index + 1, text, PTSD_CHOICES)),
    scoreRanges: [
      { label: 'لا يوجد إلى الحد الأدنى', minScore: 0, maxScore: 10 },
      { label: 'خفيف', minScore: 11, maxScore: 30, note: 'الى الدعم النفسى' },
      { label: 'متوسط', minScore: 31, maxScore: 50 },
      { label: 'شديد', minScore: 51, maxScore: 80 },
    ],
  },
  {
    key: 'QOL',
    name: 'Quality of Life (EORTC QLQ-C30)',
    description:
      'استبيان جودة الحياة EORTC QLQ-C30: 30 بنداً على مقاييس وظيفية (PF, RF, EF, CF, SF) ' +
      'وأعراض (FA, NV, PA, DY, SL, AP, CO, DI) ومالية (FI) وصحة عامة (GH). يتطلب تقييماً يدوياً.',
    category: 'Quality of Life',
    scoringType: 'MANUAL',
    interpretationMode: 'MANUAL',
    questions: qolQuestions(),
    scoreRanges: [],
  },
  {
    key: 'MACS',
    name: 'Mini-MAC – Mental Adjustment to Cancer Scale',
    description:
      'مقياس التوافق العقلي لمرضى السرطان Mini-MAC: 29 بنداً على خمسة مقاييس فرعية ' +
      '(HH=يأس/عجز، AP=انشغال قلقي، FS=روح المقاومة، CA=تجنب معرفي، FA=قدرية). يتطلب تقييماً يدوياً.',
    category: 'Adjustment',
    scoringType: 'MANUAL',
    interpretationMode: 'MANUAL',
    questions: MACS_ITEMS.map((item, index) =>
      selectQuestion(index + 1, item.text, MACS_CHOICES, item.subscale)
    ),
    scoreRanges: [],
  },
] as const;

export const DEFAULT_FORMS: readonly CreateFormInput[] = rawDefaults.map((form) =>
  createFormSchema.parse(form)
);
