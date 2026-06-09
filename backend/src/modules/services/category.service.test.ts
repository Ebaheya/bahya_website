import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { ServiceErrors } from './service.errors';
import * as categoryService from './category.service';

jest.mock('../../config/prisma', () => ({
  prisma: {
    serviceCategory: {
      findFirst: jest.fn(),
      create: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      findMany: jest.fn(),
      count: jest.fn(),
    },
  },
}));

jest.mock('../../middleware/audit', () => ({
  writeAudit: jest.fn(),
}));

const prismaMock = prisma as unknown as {
  serviceCategory: {
    findFirst: jest.Mock;
    create: jest.Mock;
    findUnique: jest.Mock;
    update: jest.Mock;
    findMany: jest.Mock;
    count: jest.Mock;
  };
};

const writeAuditMock = writeAudit as jest.Mock;

const categoryId = '11111111-1111-4111-8111-111111111111';
const actorId = '22222222-2222-4222-8222-222222222222';

function category(overrides: Record<string, unknown> = {}) {
  return {
    id: categoryId,
    name: 'Education',
    kind: 'EDUCATIONAL',
    iconKey: 'school',
    color: '#6CCB4F',
    isDefault: false,
    isActive: true,
    createdById: actorId,
    createdAt: new Date('2026-06-10T00:00:00.000Z'),
    updatedAt: new Date('2026-06-10T00:00:00.000Z'),
    ...overrides,
  };
}

describe('service category service', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    writeAuditMock.mockResolvedValue(undefined);
  });

  it('creates a category when the name is unique case-insensitively', async () => {
    prismaMock.serviceCategory.findFirst.mockResolvedValue(null);
    prismaMock.serviceCategory.create.mockResolvedValue(category());

    await expect(
      categoryService.createCategory(
        { name: 'Education', kind: 'EDUCATIONAL', iconKey: 'school', color: '#6CCB4F' },
        actorId
      )
    ).resolves.toMatchObject({ id: categoryId, name: 'Education', isActive: true });

    expect(prismaMock.serviceCategory.findFirst).toHaveBeenCalledWith({
      where: { name: { equals: 'Education', mode: 'insensitive' } },
      select: { id: true },
    });
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId,
        action: 'SERVICE_CATEGORY_CREATED',
        entityType: 'SERVICE_CATEGORY',
        entityId: categoryId,
      })
    );
  });

  it('rejects a duplicate category name case-insensitively', async () => {
    prismaMock.serviceCategory.findFirst.mockResolvedValue({ id: 'existing-category' });

    await expect(
      categoryService.createCategory(
        { name: 'education', kind: 'EDUCATIONAL', iconKey: 'school', color: '#6CCB4F' },
        actorId
      )
    ).rejects.toMatchObject({
      statusCode: 409,
      code: ServiceErrors.categoryNameTaken().code,
    });
    expect(prismaMock.serviceCategory.create).not.toHaveBeenCalled();
  });

  it('updates a category after excluding itself from the duplicate-name check', async () => {
    prismaMock.serviceCategory.findUnique.mockResolvedValue(category());
    prismaMock.serviceCategory.findFirst.mockResolvedValue(null);
    prismaMock.serviceCategory.update.mockResolvedValue(
      category({ name: 'Education Plus', color: '#4F8CFF' })
    );

    await expect(
      categoryService.updateCategory(
        categoryId,
        { name: 'Education Plus', color: '#4F8CFF' },
        actorId
      )
    ).resolves.toMatchObject({ name: 'Education Plus', color: '#4F8CFF' });

    expect(prismaMock.serviceCategory.findFirst).toHaveBeenCalledWith({
      where: {
        id: { not: categoryId },
        name: { equals: 'Education Plus', mode: 'insensitive' },
      },
      select: { id: true },
    });
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        action: 'SERVICE_CATEGORY_UPDATED',
        oldValues: expect.objectContaining({ name: 'Education' }),
        newValues: expect.objectContaining({ name: 'Education Plus' }),
      })
    );
  });

  it('deactivates a category without deleting it', async () => {
    prismaMock.serviceCategory.findUnique.mockResolvedValue(category({ isActive: true }));
    prismaMock.serviceCategory.update.mockResolvedValue(category({ isActive: false }));

    await expect(categoryService.setCategoryStatus(categoryId, false, actorId)).resolves.toMatchObject({
      id: categoryId,
      isActive: false,
    });

    expect(prismaMock.serviceCategory.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: categoryId },
        data: { isActive: false },
      })
    );
    expect(writeAuditMock).toHaveBeenCalledWith(
      expect.objectContaining({
        action: 'SERVICE_CATEGORY_DEACTIVATED',
        oldValues: { isActive: true },
        newValues: { isActive: false },
      })
    );
  });

  it('lists categories with kind and isActive filters', async () => {
    prismaMock.serviceCategory.findMany.mockResolvedValue([category()]);
    prismaMock.serviceCategory.count.mockResolvedValue(1);

    await expect(
      categoryService.listCategories({ kind: 'EDUCATIONAL', isActive: true, page: 1, pageSize: 20 })
    ).resolves.toMatchObject({
      total: 1,
      data: [expect.objectContaining({ kind: 'EDUCATIONAL' })],
    });

    expect(prismaMock.serviceCategory.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { kind: 'EDUCATIONAL', isActive: true },
      })
    );
  });
});
