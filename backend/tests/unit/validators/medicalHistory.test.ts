import { medicalHistorySchema } from '../../../src/modules/patients/validators/medicalHistory';

describe('medicalHistorySchema', () => {
  it('accepts a valid shape', () => {
    expect(
      medicalHistorySchema.parse({
        allergies: ['penicillin'],
        conditions: ['anxiety'],
        notes: 'Family history of depression',
      })
    ).toEqual({
      allergies: ['penicillin'],
      conditions: ['anxiety'],
      notes: 'Family history of depression',
    });
  });

  it('rejects unknown keys', () => {
    expect(() => medicalHistorySchema.parse({ unexpected: true })).toThrow();
  });

  it('rejects wrong types', () => {
    expect(() => medicalHistorySchema.parse({ allergies: 'penicillin' })).toThrow();
  });

  it('accepts an empty object', () => {
    expect(medicalHistorySchema.parse({})).toEqual({});
  });
});
