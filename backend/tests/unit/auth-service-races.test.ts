const mockTx = {
  passwordResetToken: { updateMany: jest.fn() },
  user: { updateMany: jest.fn() },
  refreshToken: { updateMany: jest.fn() },
};

const mockPrisma = {
  passwordResetToken: { findUnique: jest.fn() },
  $transaction: jest.fn((callback: (tx: typeof mockTx) => unknown) => callback(mockTx)),
};

jest.mock('../../src/config/prisma', () => ({ prisma: mockPrisma }));
jest.mock('../../src/config/logger', () => ({ logger: { error: jest.fn() } }));
jest.mock('../../src/utils/passwords', () => ({
  hashPassword: jest.fn().mockResolvedValue('new-password-hash'),
  verifyPassword: jest.fn(),
}));
jest.mock('../../src/utils/tokens', () => ({
  generateRefreshToken: jest.fn(),
  hashRefreshToken: jest.fn(),
  signAccessToken: jest.fn(),
}));
jest.mock('../../src/middleware/audit', () => ({
  writeAudit: jest.fn(),
  getClientIp: jest.fn(),
}));
jest.mock('../../src/modules/email/email.service', () => ({ sendEmail: jest.fn() }));
jest.mock('../../src/modules/email/templates/password-reset', () => ({
  buildPasswordResetEmail: jest.fn(),
}));
jest.mock('../../src/modules/users/user.service', () => ({
  publicUserSelect: {},
  findByEmail: jest.fn(),
  findById: jest.fn(),
  createUser: jest.fn(),
  countByRole: jest.fn(),
  revokeAllTokens: jest.fn(),
}));
jest.mock('../../src/modules/auth/reset-tokens', () => ({
  buildResetUrl: jest.fn(),
  hashResetToken: jest.fn().mockReturnValue('reset-token-hash'),
  invalidateResetToken: jest.fn(),
  issueResetToken: jest.fn(),
}));

describe('resetPassword race guards', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockPrisma.$transaction.mockImplementation((callback) => callback(mockTx));
  });

  it('revalidates token expiry and user activity inside the transaction', async () => {
    const { resetPassword } = await import('../../src/modules/auth/auth.service');
    mockPrisma.passwordResetToken.findUnique.mockResolvedValue({
      id: 'reset-token-id',
      userId: 'user-id',
      usedAt: null,
      expiresAt: new Date(Date.now() + 60 * 1000),
      user: { id: 'user-id', isActive: true },
    });
    mockTx.passwordResetToken.updateMany.mockResolvedValue({ count: 0 });

    await expect(resetPassword('raw-token', 'NewPass123!')).rejects.toMatchObject({
      code: 'INVALID_OR_EXPIRED_TOKEN',
    });

    expect(mockTx.passwordResetToken.updateMany).toHaveBeenCalledWith({
      where: {
        id: 'reset-token-id',
        usedAt: null,
        expiresAt: { gt: expect.any(Date) },
        user: { is: { isActive: true } },
      },
      data: { usedAt: expect.any(Date) },
    });
    expect(mockTx.user.updateMany).not.toHaveBeenCalled();
    expect(mockTx.refreshToken.updateMany).not.toHaveBeenCalled();
  });
});
