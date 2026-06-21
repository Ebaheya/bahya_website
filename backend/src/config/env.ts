import 'dotenv/config';
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z
    .string()
    .default('3000')
    .transform((v) => parseInt(v, 10))
    .pipe(z.number().int().positive()),
  LOG_LEVEL: z.enum(['fatal', 'error', 'warn', 'info', 'debug', 'trace']).default('info'),

  DATABASE_URL: z.string().url(),

  // z.string().url() uses the WHATWG URL parser which rejects valid multi-host
  // replica set URIs like mongodb://h1:27017,h2:27017/db (comma-separated hosts).
  // We validate the scheme manually so all Mongoose-supported URI forms are accepted:
  //   • mongodb://host/db           (single host)
  //   • mongodb://h1,h2,h3/db       (replica set, no SRV)
  //   • mongodb+srv://cluster/db    (SRV / Atlas)
  MONGODB_URI: z
    .string()
    .refine((v) => /^mongodb(?:\+srv)?:\/\/.+/.test(v), {
      message: 'MONGODB_URI must start with mongodb:// or mongodb+srv://',
    }),

  JWT_ACCESS_SECRET: z.string().min(32, 'JWT_ACCESS_SECRET must be at least 32 chars'),
  JWT_REFRESH_SECRET: z.string().min(32, 'JWT_REFRESH_SECRET must be at least 32 chars'),
  ACCESS_TOKEN_TTL: z.string().default('15m'),
  REFRESH_TOKEN_TTL_DAYS: z
    .string()
    .default('7')
    .transform((v) => parseInt(v, 10))
    .pipe(z.number().int().positive()),

  BOOTSTRAP_SECRET: z.string().min(16, 'BOOTSTRAP_SECRET must be at least 16 chars'),

  CORS_ORIGINS: z.string().default('*'),

  // Controls Express's `trust proxy` setting. When true, req.ip is taken from
  // X-Forwarded-For — required behind a reverse proxy (Nginx, ALB) so per-IP
  // rate limits and audit logs reflect the real client. When false, XFF is
  // ignored and the socket address is used. Leaving this on without a proxy
  // in front lets attackers spoof X-Forwarded-For to defeat rate limits.
  TRUST_PROXY: z
    .string()
    .default('false')
    .transform((v) => v === 'true' || v === '1')
    .pipe(z.boolean()),

  SMTP_HOST: z.string().default('localhost'),
  SMTP_PORT: z
    .string()
    .default('1025')
    .transform((v) => parseInt(v, 10))
    .pipe(z.number().int().positive()),
  SMTP_USER: z.string().default(''),
  SMTP_PASS: z.string().default(''),
  SMTP_FROM: z.string().default('noreply@bahya.health'),
  RESET_TOKEN_TTL_MINUTES: z
    .string()
    .default('30')
    .transform((v) => parseInt(v, 10))
    .pipe(z.number().int().positive()),
  APP_URL: z.string().url().default('http://localhost:3000'),

  FCM_ENABLED: z
    .string()
    .default('false')
    .transform((v) => v === 'true' || v === '1')
    .pipe(z.boolean()),
  FIREBASE_SERVICE_ACCOUNT: z.string().default(''),
  GOOGLE_APPLICATION_CREDENTIALS: z.string().default(''),

  BAHYA_AI_BASE_URL: z.string().url(),
  BAHYA_AI_API_KEY: z.string().min(1, 'BAHYA_AI_API_KEY is required'),
  BAHYA_AI_TIMEOUT_MS: z
    .string()
    .default('8000')
    .transform((v) => parseInt(v, 10))
    .pipe(z.number().int().positive()),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('Invalid environment variables:', parsed.error.flatten().fieldErrors);
  process.exit(1);
}

export const env = parsed.data;

// Wildcard CORS is rejected in production: browsers block credentialed requests
// to wildcard origins, and it exposes the API to arbitrary browser origins.
if (env.NODE_ENV === 'production' && env.CORS_ORIGINS === '*') {
  console.error(
    'CORS_ORIGINS must be set to an explicit comma-separated allow-list in production. ' +
      'Wildcard (*) is not permitted.'
  );
  process.exit(1);
}

// The AI gateway sends PHI (patient message, history, oncology profile) plus a
// bearer key to BAHYA_AI_BASE_URL. In production that link MUST be encrypted;
// only loopback is allowed over plain http (local dev / sidecar).
if (env.NODE_ENV === 'production' && !/^https:\/\//i.test(env.BAHYA_AI_BASE_URL)) {
  const host = (() => {
    try {
      // URL.hostname keeps brackets for IPv6 (e.g. "[::1]"); strip them so the
      // loopback check matches "::1".
      return new URL(env.BAHYA_AI_BASE_URL).hostname.replace(/^\[|\]$/g, '');
    } catch {
      return '';
    }
  })();
  const isLoopback = host === 'localhost' || host === '127.0.0.1' || host === '::1';
  if (!isLoopback) {
    console.error(
      'BAHYA_AI_BASE_URL must use https:// in production (PHI + bearer key are sent to it).'
    );
    process.exit(1);
  }
}

export const corsOrigins =
  env.CORS_ORIGINS === '*'
    ? '*'
    : env.CORS_ORIGINS.split(',')
        .map((s) => s.trim())
        .filter(Boolean);

// Enable credentials only when an explicit origin allow-list is configured.
// The API uses Authorization: Bearer tokens, so credentials (cookies) are not
// needed by default — turn this on when a cookie-based flow is added.
export const corsCredentials = corsOrigins !== '*';
