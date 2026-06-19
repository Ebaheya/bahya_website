const mockPrisma = {
  user: {
    findMany: jest.fn(),
    count: jest.fn(),
  },
  $transaction: jest.fn((operations: Array<Promise<unknown>>) => Promise.all(operations)),
};

jest.mock('../../config/prisma', () => ({ prisma: mockPrisma }));
jest.mock('../../config/logger', () => ({ logger: { error: jest.fn() } }));
jest.mock('../../middleware/audit', () => ({ writeAudit: jest.fn() }));
jest.mock('../email/email.service', () => ({ sendEmail: jest.fn() }));
jest.mock('../email/templates/password-reset', () => ({
  buildPasswordResetEmail: jest.fn(),
}));
jest.mock('../auth/reset-tokens', () => ({
  buildResetUrl: jest.fn(),
  invalidateResetToken: jest.fn(),
  issueResetToken: jest.fn(),
}));

describe('volunteer assignment options', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockPrisma.$transaction.mockImplementation((operations) => Promise.all(operations));
  });

  it('returns active volunteers matched by name with minimal selectable fields', async () => {
    const { listVolunteerOptions } = await import('./user.service');
    const { listVolunteerOptionsQuerySchema } = await import('./user.schema');

    const volunteers = [{ id: 'volunteer-id', fullName: 'Amira Hassan' }];
    mockPrisma.user.findMany.mockResolvedValue(volunteers);
    mockPrisma.user.count.mockResolvedValue(1);

    const query = listVolunteerOptionsQuerySchema.parse({ q: '  Amira  ' });
    const result = await listVolunteerOptions(query);

    expect(result).toEqual({ data: volunteers, page: 1, pageSize: 20, total: 1 });
    expect(mockPrisma.user.findMany).toHaveBeenCalledWith({
      where: {
        role: 'VOLUNTEER',
        isActive: true,
        fullName: { contains: 'Amira', mode: 'insensitive' },
      },
      select: { id: true, fullName: true },
      orderBy: { fullName: 'asc' },
      skip: 0,
      take: 20,
    });
    expect(mockPrisma.user.count).toHaveBeenCalledWith({
      where: {
        role: 'VOLUNTEER',
        isActive: true,
        fullName: { contains: 'Amira', mode: 'insensitive' },
      },
    });
  });

  it('rejects filters that would expose inactive users or other roles', async () => {
    const { listVolunteerOptionsQuerySchema } = await import('./user.schema');

    expect(() => listVolunteerOptionsQuerySchema.parse({ role: 'ADMIN' })).toThrow();
    expect(() => listVolunteerOptionsQuerySchema.parse({ isActive: 'false' })).toThrow();
  });
});
