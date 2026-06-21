import { Schema, model, models, type Types } from 'mongoose';

export const CHAT_RISK_LEVELS = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'] as const;
export type ChatRiskLevel = (typeof CHAT_RISK_LEVELS)[number];

export const CHAT_SESSION_STATUSES = ['ACTIVE', 'CLOSED'] as const;
export type ChatSessionStatus = (typeof CHAT_SESSION_STATUSES)[number];

export const CHAT_SENDERS = ['PATIENT', 'BOT'] as const;
export type ChatSender = (typeof CHAT_SENDERS)[number];

export const CHAT_LANGUAGES = ['ar', 'en'] as const;
export type ChatLanguage = (typeof CHAT_LANGUAGES)[number];

export const CHAT_INTENTS = [
  'emotional_support',
  'food_query',
  'medical_info',
  'crisis',
  'small_talk',
] as const;
export type ChatIntent = (typeof CHAT_INTENTS)[number];

export const CRISIS_SIGNAL_TYPES = ['indirect', 'direct'] as const;
export type CrisisSignalType = (typeof CRISIS_SIGNAL_TYPES)[number];

export interface ChatSessionDoc {
  patientId: string;
  status: ChatSessionStatus;
  maxRiskLevel: ChatRiskLevel | null;
  lastEmotion: string | null;
  summary: string | null;
  startedAt: Date;
  endedAt: Date | null;
  lastActivityAt: Date;
}

export interface ChatMessageDoc {
  sessionId: Types.ObjectId;
  patientId: string;
  sender: ChatSender;
  message: string;
  lang: ChatLanguage | null;
  emotion: string | null;
  emotionConfidence: number | null;
  intent: ChatIntent | null;
  riskLevel: ChatRiskLevel | null;
  crisisProbability: number | null;
  crisis: boolean | null;
  crisisSignalType: CrisisSignalType | null;
  flaggedPhrases: string[];
  phq9Score: number | null;
  createdAt: Date;
}

const ChatSessionSchema = new Schema<ChatSessionDoc>(
  {
    patientId: { type: String, required: true },
    status: { type: String, enum: CHAT_SESSION_STATUSES, required: true, default: 'ACTIVE' },
    maxRiskLevel: { type: String, enum: CHAT_RISK_LEVELS, default: null },
    lastEmotion: { type: String, default: null },
    summary: { type: String, default: null },
    startedAt: { type: Date, required: true },
    endedAt: { type: Date, default: null },
    lastActivityAt: { type: Date, required: true },
  },
  { collection: 'chat_sessions', versionKey: false, strict: 'throw' }
);

ChatSessionSchema.index({ patientId: 1, status: 1 });
ChatSessionSchema.index({ patientId: 1, startedAt: -1 });
// Enforce "at most one open session per patient" at the DB level so a concurrent
// double-send can't create two ACTIVE sessions (the service handles the E11000).
ChatSessionSchema.index(
  { patientId: 1 },
  { unique: true, partialFilterExpression: { status: 'ACTIVE' } }
);

const ChatMessageSchema = new Schema<ChatMessageDoc>(
  {
    sessionId: { type: Schema.Types.ObjectId, required: true, ref: 'ChatSession' },
    patientId: { type: String, required: true },
    sender: { type: String, enum: CHAT_SENDERS, required: true },
    message: { type: String, required: true },
    lang: { type: String, enum: CHAT_LANGUAGES, default: null },
    emotion: { type: String, default: null },
    emotionConfidence: { type: Number, min: 0, max: 1, default: null },
    intent: { type: String, enum: CHAT_INTENTS, default: null },
    riskLevel: { type: String, enum: CHAT_RISK_LEVELS, default: null },
    crisisProbability: { type: Number, min: 0, max: 1, default: null },
    crisis: { type: Boolean, default: null },
    crisisSignalType: { type: String, enum: CRISIS_SIGNAL_TYPES, default: null },
    flaggedPhrases: { type: [String], default: [] },
    phq9Score: { type: Number, default: null },
    createdAt: { type: Date, required: true },
  },
  { collection: 'chat_messages', versionKey: false, strict: 'throw' }
);

// _id included so the (createdAt, _id) tie-break sort stays index-covered.
ChatMessageSchema.index({ sessionId: 1, createdAt: 1, _id: 1 });
ChatMessageSchema.index({ patientId: 1, createdAt: -1 });

export const ChatSessionModel =
  models.ChatSession ?? model<ChatSessionDoc>('ChatSession', ChatSessionSchema);

export const ChatMessageModel =
  models.ChatMessage ?? model<ChatMessageDoc>('ChatMessage', ChatMessageSchema);
