import { AppError } from '../../utils/httpError';

export const CHATBOT_ERROR = {
  AI_INFERENCE_FAILED: 'AI_INFERENCE_FAILED',
  SESSION_NOT_FOUND: 'CHAT_SESSION_NOT_FOUND',
} as const;

export const chatErrors = {
  aiInferenceFailed(message = 'AI inference failed'): AppError {
    return new AppError(502, CHATBOT_ERROR.AI_INFERENCE_FAILED, message);
  },

  sessionNotFound(message = 'Chat session not found'): AppError {
    return new AppError(404, CHATBOT_ERROR.SESSION_NOT_FOUND, message);
  },
};
