import { z } from 'zod';
import { env } from '../../config/env';
import { chatErrors } from './chat.errors';
import {
  CHAT_INTENTS,
  CHAT_LANGUAGES,
  CHAT_RISK_LEVELS,
  CRISIS_SIGNAL_TYPES,
  type ChatIntent,
  type ChatLanguage,
  type ChatRiskLevel,
  type CrisisSignalType,
} from './chat.model';

const AI_CONTRACT_VERSION = 1;

// Every field we persist from the AI is bounded: the AI service is a trust
// boundary, so a buggy/compromised response must not bloat Mongo docs, balloon
// the reply fed back into history, or store nonsensical clinical values. Unknown
// top-level keys are stripped (default) rather than stored.
const aiResponseSchema = z.object({
  version: z.literal(AI_CONTRACT_VERSION),
  reply: z.string().min(1).max(8000),
  lang: z.enum(CHAT_LANGUAGES),
  emotion: z
    .object({
      label: z.string().min(1).max(100),
      confidence: z.number().min(0).max(1),
    })
    .nullable()
    .optional(),
  intent: z.enum(CHAT_INTENTS),
  riskLevel: z.enum(CHAT_RISK_LEVELS),
  crisisProbability: z.number().min(0).max(1).nullable().optional(),
  crisis: z.boolean(),
  crisisSignalType: z.enum(CRISIS_SIGNAL_TYPES).nullable().optional(),
  flaggedPhrases: z.array(z.string().max(500)).max(50),
  phq9Score: z.number().int().min(0).max(27).nullable().optional(),
  extra: z.record(z.unknown()).optional(),
});

export interface AiPatientProfile {
  patientId: string;
  age: number | null;
  languagePref: ChatLanguage;
  cancerStage: string | null;
  diseaseStatus: string | null;
  treatments: string[];
  dietNotes: string | null;
  riskFlagFromHistory: ChatRiskLevel | null;
}

export interface AiHistoryTurn {
  sender: 'PATIENT' | 'BOT';
  text: string;
  emotion: string | null;
  riskLevel: ChatRiskLevel | null;
  createdAt: string;
}

export interface AiInferRequest {
  version: typeof AI_CONTRACT_VERSION;
  sessionId: string;
  message: string;
  langHint?: ChatLanguage;
  patient: AiPatientProfile;
  history: AiHistoryTurn[];
}

export interface AiInferResponse {
  version: typeof AI_CONTRACT_VERSION;
  reply: string;
  lang: ChatLanguage;
  emotion?: { label: string; confidence: number } | null;
  intent: ChatIntent;
  riskLevel: ChatRiskLevel;
  crisisProbability?: number | null;
  crisis: boolean;
  crisisSignalType?: CrisisSignalType | null;
  flaggedPhrases: string[];
  phq9Score?: number | null;
  extra?: Record<string, unknown>;
}

export async function infer(payload: AiInferRequest): Promise<AiInferResponse> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), env.BAHYA_AI_TIMEOUT_MS);

  try {
    const response = await fetch(`${env.BAHYA_AI_BASE_URL.replace(/\/$/, '')}/infer`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${env.BAHYA_AI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
      signal: controller.signal,
    });

    if (!response.ok) throw chatErrors.aiInferenceFailed();

    const body = await response.json();
    const parsed = aiResponseSchema.safeParse(body);
    if (!parsed.success) throw chatErrors.aiInferenceFailed();

    return parsed.data;
  } catch {
    throw chatErrors.aiInferenceFailed();
  } finally {
    clearTimeout(timeout);
  }
}
