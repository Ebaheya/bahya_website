import { ChatMessageModel, ChatSessionModel } from './chat.model';

describe('chat mongoose models', () => {
  it('uses the required MongoDB collections', () => {
    expect(ChatSessionModel.collection.name).toBe('chat_sessions');
    expect(ChatMessageModel.collection.name).toBe('chat_messages');
  });

  it('defines the session indexes required by the clinical review and open-session paths', () => {
    const indexes = ChatSessionModel.schema.indexes().map((index) => index[0]);

    expect(indexes).toContainEqual({ patientId: 1, status: 1 });
    expect(indexes).toContainEqual({ patientId: 1, startedAt: -1 });
  });

  it('defines the message indexes required by history and patient timeline reads', () => {
    const indexes = ChatMessageModel.schema.indexes().map((index) => index[0]);

    expect(indexes).toContainEqual({ sessionId: 1, createdAt: 1 });
    expect(indexes).toContainEqual({ patientId: 1, createdAt: -1 });
  });

  it('keeps AI signals nullable on patient turns and required only by service flow', () => {
    const doc = new ChatMessageModel({
      sessionId: '6650f1a2c3d4e5f6a7b8c9d0',
      patientId: '8f3b7f60-997b-4e12-b45a-63f6d7dbb7ef',
      sender: 'PATIENT',
      message: 'hello',
      createdAt: new Date('2026-06-20T01:00:00Z'),
    });

    expect(doc.lang).toBeNull();
    expect(doc.riskLevel).toBeNull();
    expect(doc.flaggedPhrases).toEqual([]);
  });
});
