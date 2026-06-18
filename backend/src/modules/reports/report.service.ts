import { Prisma, type ReportStatus } from '@prisma/client';
import type { Request } from 'express';
import { prisma } from '../../config/prisma';
import { writeAudit } from '../../middleware/audit';
import { buildPaginatedResponse } from '../../utils/pagination';
import { ReportErrors } from './report.errors';
import type { CreateReportInput, ListReportsQuery } from './report.schema';

const reporterSelect = {
  id: true,
  fullName: true,
  email: true,
  role: true,
} satisfies Prisma.UserSelect;

const listReportSelect = {
  id: true,
  title: true,
  status: true,
  createdAt: true,
  reporter: { select: reporterSelect },
} satisfies Prisma.ReportSelect;

const detailReportSelect = {
  id: true,
  reporterId: true,
  title: true,
  body: true,
  status: true,
  handledById: true,
  handledAt: true,
  createdAt: true,
  updatedAt: true,
  reporter: { select: reporterSelect },
  handledBy: { select: reporterSelect },
} satisfies Prisma.ReportSelect;

const createReportSelect = {
  id: true,
  title: true,
  status: true,
  createdAt: true,
} satisfies Prisma.ReportSelect;

type ListReportRow = Prisma.ReportGetPayload<{ select: typeof listReportSelect }>;
type DetailReportRow = Prisma.ReportGetPayload<{ select: typeof detailReportSelect }>;

function toListItem(report: ListReportRow) {
  return {
    id: report.id,
    title: report.title,
    status: report.status,
    createdAt: report.createdAt,
    reporter: report.reporter,
  };
}

function toDetail(report: DetailReportRow) {
  return {
    id: report.id,
    reporterId: report.reporterId,
    title: report.title,
    body: report.body,
    status: report.status,
    handledById: report.handledById,
    handledAt: report.handledAt,
    createdAt: report.createdAt,
    updatedAt: report.updatedAt,
    reporter: report.reporter,
    handledBy: report.handledBy,
  };
}

async function getDetailOrThrow(id: string): Promise<DetailReportRow> {
  const report = await prisma.report.findUnique({
    where: { id },
    select: detailReportSelect,
  });
  if (!report) throw ReportErrors.reportNotFound();
  return report;
}

export async function createReport(
  input: CreateReportInput,
  actorId: string,
  req?: Request
) {
  const report = await prisma.report.create({
    data: {
      title: input.title,
      body: input.body,
      reporterId: actorId,
      status: 'PENDING',
    },
    select: createReportSelect,
  });

  await writeAudit({
    actorId,
    action: 'REPORT_CREATED',
    entityType: 'REPORT',
    entityId: report.id,
    newValues: {
      title: report.title,
      status: report.status,
      reporterId: actorId,
    },
    req,
  });

  return report;
}

export async function listReports(query: ListReportsQuery) {
  const where: Prisma.ReportWhereInput = {
    ...(query.status ? { status: query.status } : {}),
    ...(query.q
      ? {
          OR: [
            { title: { contains: query.q, mode: 'insensitive' } },
            { reporter: { fullName: { contains: query.q, mode: 'insensitive' } } },
            { reporter: { email: { contains: query.q, mode: 'insensitive' } } },
          ],
        }
      : {}),
  };
  const skip = (query.page - 1) * query.pageSize;

  const [data, total] = await prisma.$transaction([
    prisma.report.findMany({
      where,
      select: listReportSelect,
      orderBy: { createdAt: 'desc' },
      skip,
      take: query.pageSize,
    }),
    prisma.report.count({ where }),
  ]);

  return buildPaginatedResponse(data.map(toListItem), query, total);
}

export async function getReportById(id: string) {
  return toDetail(await getDetailOrThrow(id));
}

export async function getSummary() {
  const counts = await prisma.report.groupBy({
    by: ['status'],
    _count: { _all: true },
  });

  const summary = {
    pending: 0,
    investigating: 0,
    resolved: 0,
  };

  for (const count of counts) {
    if (count.status === 'PENDING') summary.pending = count._count._all;
    if (count.status === 'INVESTIGATING') summary.investigating = count._count._all;
    if (count.status === 'RESOLVED') summary.resolved = count._count._all;
  }

  return summary;
}

export async function changeStatus(
  id: string,
  status: ReportStatus,
  actorId: string,
  req?: Request
) {
  const existing = await getDetailOrThrow(id);
  if (existing.status === status) return toDetail(existing);

  const updated = await prisma.report.update({
    where: { id },
    data: {
      status,
      handledById: actorId,
      handledAt: new Date(),
    },
    select: detailReportSelect,
  });

  await writeAudit({
    actorId,
    action: 'REPORT_STATUS_CHANGED',
    entityType: 'REPORT',
    entityId: id,
    oldValues: { status: existing.status },
    newValues: { status: updated.status },
    req,
  });

  return toDetail(updated);
}
