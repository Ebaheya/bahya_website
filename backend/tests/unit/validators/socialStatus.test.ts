import { socialStatusSchema } from '../../../src/modules/patients/validators/socialStatus';

describe('socialStatusSchema', () => {
  it('accepts a valid shape', () => {
    expect(
      socialStatusSchema.parse({
        maritalStatus: 'SINGLE',
        familySupport: 'MEDIUM',
        notes: 'Lives with family',
      })
    ).toEqual({
      maritalStatus: 'SINGLE',
      familySupport: 'MEDIUM',
      notes: 'Lives with family',
    });
  });

  it('rejects unknown keys', () => {
    expect(() => socialStatusSchema.parse({ unexpected: true })).toThrow();
  });

  it('rejects wrong types', () => {
    expect(() => socialStatusSchema.parse({ familySupport: ['MEDIUM'] })).toThrow();
  });

  it('accepts an empty object', () => {
    expect(socialStatusSchema.parse({})).toEqual({});
  });
});
