import { financialsSchema } from '../../../src/modules/patients/validators/financials';

describe('financialsSchema', () => {
  it('accepts a valid shape', () => {
    expect(
      financialsSchema.parse({
        incomeBracket: 'LOW',
        notes: 'Eligible for support',
      })
    ).toEqual({
      incomeBracket: 'LOW',
      notes: 'Eligible for support',
    });
  });

  it('rejects unknown keys', () => {
    expect(() => financialsSchema.parse({ unexpected: true })).toThrow();
  });

  it('rejects wrong types', () => {
    expect(() => financialsSchema.parse({ notes: 123 })).toThrow();
  });

  it('accepts an empty object', () => {
    expect(financialsSchema.parse({})).toEqual({});
  });
});
