import mongoose from 'mongoose';
import { env } from './env';
import { logger } from './logger';

export async function connectMongo(): Promise<void> {
  await mongoose.connect(env.MONGODB_URI, {
    // Fail fast: if MongoDB is unreachable at startup, surface the error
    // immediately rather than retrying indefinitely.
    serverSelectionTimeoutMS: 5000,
  });
  logger.info({ uri: env.MONGODB_URI.replace(/\/\/[^@]*@/, '//***@') }, 'mongodb connected');
}

export async function disconnectMongo(): Promise<void> {
  await mongoose.disconnect();
  logger.info('mongodb disconnected');
}
