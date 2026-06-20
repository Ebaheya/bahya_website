import type { AiInferRequest } from './ai.client';

const validPayload: AiInferRequest = {
  version: 1,
  sessionId: '6650f1a2c3d4e5f6a7b8c9d0',
  message: 'hello',
  patient: {
    patientId: '8f3b7f60-997b-4e12-b45a-63f6d7dbb7ef',
    age: 36,
    languagePref: 'ar',
    cancerStage: 'STAGE_II',
    diseaseStatus: 'ACTIVE_TREATMENT',
    treatments: ['ADJUVANT_CHEMO'],
    dietNotes: 'lactose intolerant',
    riskFlagFromHistory: 'MEDIUM',
  },
  history: [],
};

const validResponse = {
  version: 1,
  reply: 'I am here with you.',
  lang: 'en',
  emotion: { label: 'sadness', confidence: 0.88 },
  intent: 'emotional_support',
  riskLevel: 'MEDIUM',
  crisisProbability: 0.34,
  crisis: false,
  crisisSignalType: null,
  flaggedPhrases: [],
  phq9Score: null,
  extra: {},
};

async function importClient() {
  jest.resetModules();
  process.env.BAHYA_AI_BASE_URL = 'http://ai.local';
  process.env.BAHYA_AI_API_KEY = 'test-token';
  process.env.BAHYA_AI_TIMEOUT_MS = '8000';
  return import('./ai.client');
}

describe('infer', () => {
  beforeEach(() => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => validResponse,
    } as Response);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('posts the frozen AI contract to /infer with bearer auth and no retry', async () => {
    const { infer } = await importClient();

    await expect(infer(validPayload)).resolves.toEqual(validResponse);

    expect(global.fetch).toHaveBeenCalledTimes(1);
    expect(global.fetch).toHaveBeenCalledWith(
      'http://ai.local/infer',
      expect.objectContaining({
        method: 'POST',
        headers: expect.objectContaining({
          Authorization: 'Bearer test-token',
          'Content-Type': 'application/json',
        }),
        body: JSON.stringify(validPayload),
      })
    );
  });

  it('normalizes non-2xx responses to AI_INFERENCE_FAILED', async () => {
    global.fetch = jest.fn().mockResolvedValue({
      ok: false,
      status: 500,
      json: async () => ({ error: 'down' }),
    } as Response);
    const { infer } = await importClient();

    await expect(infer(validPayload)).rejects.toMatchObject({
      statusCode: 502,
      code: 'AI_INFERENCE_FAILED',
    });
    expect(global.fetch).toHaveBeenCalledTimes(1);
  });
});
