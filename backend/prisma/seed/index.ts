import { PrismaClient } from '@prisma/client';
import { seedDefaultForms } from './forms';
import { seedDefaultServiceCategories } from './services';

async function main(): Promise<void> {
  const client = new PrismaClient();
  try {
    const formCount = await seedDefaultForms(client);
    const serviceCategoryCount = await seedDefaultServiceCategories(client);
    console.log(`Seeded ${formCount} default forms.`);
    console.log(`Seeded ${serviceCategoryCount} default service categories.`);
  } finally {
    await client.$disconnect();
  }
}

if (require.main === module) {
  void main().catch((err: unknown) => {
    console.error('Failed to seed database.', err);
    process.exitCode = 1;
  });
}
