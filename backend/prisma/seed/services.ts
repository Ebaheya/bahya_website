import { PrismaClient, type Prisma, type ServiceKind } from '@prisma/client';

type DefaultServiceCategory = {
  name: string;
  kind: ServiceKind;
  iconKey: string;
  color: string;
};

const DEFAULT_SERVICE_CATEGORIES: DefaultServiceCategory[] = [
  { name: 'Educational Services', kind: 'EDUCATIONAL', iconKey: 'school', color: '#6CCB4F' },
  { name: 'Trips and Activities', kind: 'TRIP', iconKey: 'directions_bus', color: '#4F8CFF' },
  { name: 'Psychological Support', kind: 'SUPPORT', iconKey: 'psychology', color: '#B46CFF' },
  { name: 'Awareness Sessions', kind: 'EDUCATIONAL', iconKey: 'menu_book', color: '#FFB84F' },
  { name: 'Group Support', kind: 'SUPPORT', iconKey: 'groups', color: '#FF6F91' },
  { name: 'Recreational Trips', kind: 'TRIP', iconKey: 'celebration', color: '#00A6A6' },
];

export async function seedDefaultServiceCategories(client: PrismaClient): Promise<number> {
  for (const category of DEFAULT_SERVICE_CATEGORIES) {
    const existing = await client.serviceCategory.findFirst({
      where: { name: { equals: category.name, mode: 'insensitive' } },
      select: { id: true },
    });

    const data: Prisma.ServiceCategoryUncheckedCreateInput = {
      name: category.name,
      kind: category.kind,
      iconKey: category.iconKey,
      color: category.color,
      isDefault: true,
      isActive: true,
      createdById: null,
    };

    if (existing) {
      await client.serviceCategory.update({
        where: { id: existing.id },
        data: {
          kind: category.kind,
          iconKey: category.iconKey,
          color: category.color,
          isDefault: true,
          isActive: true,
        },
      });
    } else {
      await client.serviceCategory.create({ data });
    }
  }

  return DEFAULT_SERVICE_CATEGORIES.length;
}

async function main(): Promise<void> {
  const client = new PrismaClient();
  try {
    const count = await seedDefaultServiceCategories(client);
    console.log(`Seeded ${count} default service categories.`);
  } finally {
    await client.$disconnect();
  }
}

if (require.main === module) {
  void main().catch((err: unknown) => {
    console.error('Failed to seed default service categories.', err);
    process.exitCode = 1;
  });
}
