import { ZodError } from 'zod';
import {
  messagesQuerySchema,
  messageBodySchema,
  sessionsListQuerySchema,
} from './chat.schema';

describe('chat schemas', () => {
  it('trims valid patient messages and accepts an optional ObjectId session id', () => {
    const parsed = messageBodySchema.parse({
      sessionId: '6650f1a2c3d4e5f6a7b8c9d0',
      message: '  hello  ',
    });

    expect(parsed).toEqual({
      sessionId: '6650f1a2c3d4e5f6a7b8c9d0',
      message: 'hello',
    });
  });

  it('rejects blank, over-length, and malformed session ids', () => {
    expect(() => messageBodySchema.parse({ message: '   ' })).toThrow(ZodError);
    expect(() => messageBodySchema.parse({ message: 'a'.repeat(4001) })).toThrow(ZodError);
    expect(() => messageBodySchema.parse({ sessionId: 'nope', message: 'hello' })).toThrow(
      ZodError
    );
  });

  it('defaults pagination and caps page size for session and message reads', () => {
    expect(sessionsListQuerySchema.parse({})).toEqual({ page: 1, pageSize: 20 });
    expect(messagesQuerySchema.parse({ page: '2', pageSize: '100' })).toEqual({
      page: 2,
      pageSize: 100,
    });
    expect(() => messagesQuerySchema.parse({ pageSize: '101' })).toThrow(ZodError);
  });
});
