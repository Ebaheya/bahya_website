# syntax=docker/dockerfile:1

# ---- builder: install all deps, generate Prisma client, compile TS ----
FROM node:20-bookworm-slim AS builder
WORKDIR /app

# Prisma needs OpenSSL at generate time to pick the correct query engine.
RUN apt-get update \
  && apt-get install -y --no-install-recommends openssl ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json ./
RUN npm ci

COPY prisma ./prisma
RUN npx prisma generate

COPY tsconfig.json ./
COPY src ./src
RUN npm run build

# ---- runner: production image ----
FROM node:20-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production

# openssl: Prisma runtime. wget: container HEALTHCHECK probe.
RUN apt-get update \
  && apt-get install -y --no-install-recommends openssl ca-certificates wget \
  && rm -rf /var/lib/apt/lists/*

# node_modules is copied whole (incl. the Prisma CLI) so the entrypoint can run
# `prisma migrate deploy` against the generated client without a second install.
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package.json ./package.json
COPY docker-entrypoint.sh ./docker-entrypoint.sh

RUN chmod +x docker-entrypoint.sh \
  && useradd --create-home --shell /usr/sbin/nologin app \
  && chown -R app:app /app
USER app

EXPOSE 3000

# Liveness/readiness probe hits the app's own DB-aware health route.
HEALTHCHECK --interval=15s --timeout=5s --start-period=40s --retries=5 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1:3000/api/v1/health || exit 1

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["node", "dist/server.js"]
