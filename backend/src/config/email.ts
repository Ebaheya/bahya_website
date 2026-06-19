import nodemailer from 'nodemailer';
import { env } from './env';

const auth =
  env.SMTP_USER || env.SMTP_PASS
    ? {
        user: env.SMTP_USER,
        pass: env.SMTP_PASS,
      }
    : undefined;

export const emailTransport = nodemailer.createTransport({
  host: env.SMTP_HOST,
  port: env.SMTP_PORT,
  secure: env.SMTP_PORT === 465,
  auth,
});
