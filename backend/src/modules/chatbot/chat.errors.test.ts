import { AppError } from '../../utils/httpError';
import { CHATBOT_ERROR, chatErrors } from './chat.errors';

describe('chatErrors', () => {
  it('maps AI inference failures to the chatbot 502 contract', () => {
    const err = chatErrors.aiInferenceFailed();

    expect(err).toBeInstanceOf(AppError);
    expect(err.statusCode).toBe(502);
    expect(err.code).toBe(CHATBOT_ERROR.AI_INFERENCE_FAILED);
    expect(err.message).toBe('AI inference failed');
  });

  it('maps missing chat sessions to a stable 404 code', () => {
    const err = chatErrors.sessionNotFound();

    expect(err).toBeInstanceOf(AppError);
    expect(err.statusCode).toBe(404);
    expect(err.code).toBe(CHATBOT_ERROR.SESSION_NOT_FOUND);
  });
});
