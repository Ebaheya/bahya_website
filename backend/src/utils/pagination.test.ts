import {
  buildPaginatedResponse,
  parsePagination,
} from './pagination';

describe('pagination utilities', () => {
  it('defaults missing or invalid page inputs and caps pageSize', () => {
    expect(parsePagination({})).toEqual({
      page: 1,
      pageSize: 20,
      skip: 0,
      take: 20,
    });

    expect(parsePagination({ page: '3', pageSize: '500' })).toEqual({
      page: 3,
      pageSize: 100,
      skip: 200,
      take: 100,
    });

    expect(parsePagination({ page: '0', pageSize: '-4' })).toEqual({
      page: 1,
      pageSize: 20,
      skip: 0,
      take: 20,
    });
  });

  it('builds the shared paginated response envelope', () => {
    const page = parsePagination({ page: 2, pageSize: 2 });

    expect(buildPaginatedResponse(['c', 'd'], page, 5)).toEqual({
      data: ['c', 'd'],
      page: 2,
      pageSize: 2,
      total: 5,
    });
  });
});
