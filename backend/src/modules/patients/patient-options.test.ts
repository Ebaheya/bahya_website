export {};

const mockPrisma = {
  patient: {
    findMany: jest.fn(),
    count: jest.fn(),
  },
  $transaction: jest.fn((operations: Array<Promise<unknown>>) => Promise.all(operations)),
};

jest.mock('../../config/prisma', () => ({ prisma: mockPrisma }));
jest.mock('../../config/logger', () => ({ logger: { error: jest.fn() } }));
jest.mock('../../middleware/audit', () => ({ writeAudit: jest.fn() }));
jest.mock('../../utils/passwords', () => ({ hashPassword: jest.fn() }));

describe('patient assignment options', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockPrisma.$transaction.mockImplementation((operations) => Promise.all(operations));
  });

  it('returns active patients matched by name with minimal selectable fields', async () => {
    const { listPatientOptions } = await import('./patient.service');
    const { listPatientOptionsQuerySchema } = await import('./patient.schema');

    const patients = [{ id: 'patient-id', fullName: 'Sara Ali' }];
    mockPrisma.patient.findMany.mockResolvedValue([
      { id: 'patient-id', user: { fullName: 'Sara Ali' } },
    ]);
    mockPrisma.patient.count.mockResolvedValue(1);

    const query = listPatientOptionsQuerySchema.parse({ q: '  Sara  ' });
    const result = await listPatientOptions(query);

    expect(result).toEqual({ data: patients, page: 1, pageSize: 20, total: 1 });
    expect(mockPrisma.patient.findMany).toHaveBeenCalledWith({
      where: {
        user: {
          is: {
            role: 'PATIENT',
            isActive: true,
            fullName: { contains: 'Sara', mode: 'insensitive' },
          },
        },
      },
      select: { id: true, user: { select: { fullName: true } } },
      orderBy: { user: { fullName: 'asc' } },
      skip: 0,
      take: 20,
    });
  });

  it('rejects filters that could expose inactive patients', async () => {
    const { listPatientOptionsQuerySchema } = await import('./patient.schema');

    expect(() => listPatientOptionsQuerySchema.parse({ isActive: 'false' })).toThrow();
    expect(() => listPatientOptionsQuerySchema.parse({ phone: '+201001234567' })).toThrow();
  });
});
