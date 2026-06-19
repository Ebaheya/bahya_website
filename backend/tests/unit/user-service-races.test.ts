const mockWriteAudit = jest.fn();

const mockTx = {
  $executeRaw: jest.fn(),
  user: {
    findUnique: jest.fn(),
    count: jest.fn(),
    update: jest.fn(),
  },
};

const mockPrisma = {
  user: { findUnique: jest.fn() },
  refreshToken: { updateMany: jest.fn() },
  $transaction: jest.fn((callback: (tx: typeof mockTx) => unknown) => callback(mockTx)),
};

jest.mock('../../src/config/prisma', () => ({ prisma: mockPrisma }));
jest.mock('../../src/config/logger', () => ({ logger: { error: jest.fn() } }));
jest.mock('../../src/middleware/audit', () => ({ writeAudit: mockWriteAudit }));
jest.mock('../../src/modules/email/email.service', () => ({ sendEmail: jest.fn() }));
jest.mock('../../src/modules/email/templates/password-reset', () => ({
  buildPasswordResetEmail: jest.fn(),
}));
jest.mock('../../src/modules/auth/reset-tokens', () => ({
  buildResetUrl: jest.fn(),
  invalidateResetToken: jest.fn(),
  issueResetToken: jest.fn(),
}));

describe('patchUserStatus race guards', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockPrisma.$transaction.mockImplementation((callback) => callback(mockTx));
    mockPrisma.refreshToken.updateMany.mockResolvedValue({ count: 1 });
  });

  it('treats duplicate admin deactivation as idempotent after acquiring the lock', async () => {
    const { patchUserStatus } = await import('../../src/modules/users/user.service');
    const initiallyActiveAdmin = {
      id: 'target-admin-id',
      email: 'target-admin@example.com',
      fullName: 'Target Admin',
      role: 'ADMIN',
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    const alreadyInactiveAdmin = { ...initiallyActiveAdmin, isActive: false };

    mockPrisma.user.findUnique.mockResolvedValue(initiallyActiveAdmin);
    mockTx.user.findUnique.mockResolvedValue(alreadyInactiveAdmin);

    const result = await patchUserStatus('target-admin-id', false, 'actor-admin-id');

    expect(result).toBe(alreadyInactiveAdmin);
    expect(mockTx.$executeRaw).toHaveBeenCalled();
    expect(mockTx.user.count).not.toHaveBeenCalled();
    expect(mockTx.user.update).not.toHaveBeenCalled();
    expect(mockPrisma.refreshToken.updateMany).toHaveBeenCalledWith({
      where: { userId: 'target-admin-id', revokedAt: null },
      data: { revokedAt: expect.any(Date) },
    });
    expect(mockWriteAudit).not.toHaveBeenCalled();
  });
});
