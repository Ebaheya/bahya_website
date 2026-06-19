export interface PaginationOptions {
  defaultPage?: number;
  defaultPageSize?: number;
  maxPageSize?: number;
}

export interface PaginationInput {
  page?: unknown;
  pageSize?: unknown;
}

export interface Pagination {
  page: number;
  pageSize: number;
  skip: number;
  take: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  page: number;
  pageSize: number;
  total: number;
}

const DEFAULT_PAGE = 1;
const DEFAULT_PAGE_SIZE = 20;
const DEFAULT_MAX_PAGE_SIZE = 100;

function toPositiveInteger(value: unknown, fallback: number): number {
  const parsed =
    typeof value === 'number' || typeof value === 'string'
      ? Number(value)
      : Number.NaN;

  if (!Number.isFinite(parsed) || parsed < 1) return fallback;
  return Math.trunc(parsed);
}

export function parsePagination(
  input: PaginationInput,
  options: PaginationOptions = {}
): Pagination {
  const defaultPage = options.defaultPage ?? DEFAULT_PAGE;
  const defaultPageSize = options.defaultPageSize ?? DEFAULT_PAGE_SIZE;
  const maxPageSize = options.maxPageSize ?? DEFAULT_MAX_PAGE_SIZE;

  const page = toPositiveInteger(input.page, defaultPage);
  const requestedPageSize = toPositiveInteger(input.pageSize, defaultPageSize);
  const pageSize = Math.min(requestedPageSize, maxPageSize);

  return {
    page,
    pageSize,
    skip: (page - 1) * pageSize,
    take: pageSize,
  };
}

export function buildPaginatedResponse<T>(
  data: T[],
  pagination: Pick<Pagination, 'page' | 'pageSize'>,
  total: number
): PaginatedResponse<T> {
  return {
    data,
    page: pagination.page,
    pageSize: pagination.pageSize,
    total,
  };
}
