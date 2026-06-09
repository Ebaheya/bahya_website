import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { ServiceErrors } from './service.errors';
import { createServiceSchema } from './service.schema';
import * as serviceService from './service.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    serviceCategory: {
      findUnique: jest.fn(),
    },
    service: {
      create: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
  },
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: jest.fn(),
}));

const prismaMock = prisma as unknown as {
  serviceCategory: { findUnique: jest.Mock };
  service: {
    create: jest.Mock;
    findUnique: jest.Mock;
    update: jest.Mock;
  };
};

const writeAuditMock = writeAudit as jest.Mock;

const categoryId = '11111111-1111-4111-8111-111111111111';
const serviceId = '22222222-2222-4222-8222-222222222222';
const actorId = '33333333-3333-4333-8333-333333333333';

const baseInput = createServiceSchema.parse({
  categoryId,
  name: 'Literacy Class',
  locationBranch: 'Main Branch',
  startDate: '2026-07-20',
  startTime: '10:00',
  capacity: 12,
});

function persistedService(overrides: Record<string, unknown> = {}) {
  return {
    id: serviceId,
    categoryId,
    name: 'Literacy Class',
    locationBranch: 'Main Branch',
    startDate: new Date('2026-07-20T00:00:00.000Z'),
    startTime: '10:00',
    endDate: null,
    departureTime: null,
    meetingPlace: null,
    capacity: 12,
    seatsTaken: 0,
    status: 'ACTIVE',
    createdById: actorId,
    createdAt: new Date('2026-06-10T00:00:00.000Z'),
    updatedAt: new Date('2026-06-10T00:00:00.000Z'),
    category: {
      id: categoryId,
      name: 'Education',
      kind: 'EDUCATIONAL',
      iconKey: 'school',
      color: '#6CCB4F',
    },
    ...overrides,
  };
}

describe('service service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    writeAuditMock.mockResolvedValue(undefined);
  });

  it('creates a service with active status, zero seats taken, and remaining seats', async () => {
    prismaMock.serviceCategory.findUnique.mockResolvedValue({ id: categoryId, kind: 'EDUCATIONAL' });
    prismaMock.service.create.mockResolvedValue(persistedService());

    await expect(serviceService.createService(baseInput, actorId)).resolves.toMatchObject({
      id: serviceId,
      status: 'ACTIVE',
      seatsTaken: 0,
      remainingSeats: 12,
    });

    expect(prismaMock.service.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          categoryId,
          capacity: 12,
          createdById: actorId,
        }),
      })
    );
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId,
        action: 'SERVICE_CREATED',
        entityType: 'SERVICE',
        entityId: serviceId,
      })
    );
  });

  it('requires capacity greater than zero before create', async () => {
    await expect(
      serviceService.createService({ ...baseInput, capacity: 0 }, actorId)
    ).rejects.toMatchObject({
      statusCode: 400,
      code: ServiceErrors.serviceCapacityInvalid().code,
    });
    expect(prismaMock.service.create).not.toHaveBeenCalled();
  });

  it('requires trip-only fields only when the category is a trip', async () => {
    prismaMock.serviceCategory.findUnique.mockResolvedValue({ id: categoryId, kind: 'TRIP' });

    await expect(serviceService.createService(baseInput, actorId)).rejects.toMatchObject({
      statusCode: 400,
      code: ServiceErrors.tripFieldsRequired().code,
    });

    const tripInput = {
      ...baseInput,
      endDate: new Date('2026-07-21T00:00:00.000Z'),
      departureTime: '08:30',
      meetingPlace: 'Gate 2',
    };
    prismaMock.service.create.mockResolvedValue(
      persistedService({
        category: { id: categoryId, name: 'Trips', kind: 'TRIP', iconKey: 'bus', color: '#4F8CFF' },
        ...tripInput,
      })
    );

    await expect(serviceService.createService(tripInput, actorId)).resolves.toMatchObject({
      remainingSeats: 12,
      category: expect.objectContaining({ kind: 'TRIP' }),
    });
  });

  it('rejects capacity updates below seats already taken and reports the minimum', async () => {
    prismaMock.service.findUnique.mockResolvedValue(persistedService({ seatsTaken: 7 }));

    await expect(
      serviceService.updateService(serviceId, { capacity: 6 }, actorId)
    ).rejects.toMatchObject({
      statusCode: 400,
      code: ServiceErrors.serviceCapacityBelowTaken(7).code,
      details: { minimum: 7 },
    });
    expect(prismaMock.service.update).not.toHaveBeenCalled();
  });

  it('closes a service with the SERVICE_CLOSED audit action', async () => {
    prismaMock.service.findUnique.mockResolvedValue(persistedService({ seatsTaken: 3 }));
    prismaMock.service.update.mockResolvedValue(persistedService({ seatsTaken: 3, status: 'CLOSED' }));

    await expect(
      serviceService.updateService(serviceId, { status: 'CLOSED' }, actorId)
    ).resolves.toMatchObject({
      status: 'CLOSED',
      remainingSeats: 9,
    });

    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId,
        action: 'SERVICE_CLOSED',
        entityId: serviceId,
      })
    );
  });
});
