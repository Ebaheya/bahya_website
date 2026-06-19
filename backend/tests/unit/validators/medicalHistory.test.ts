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

  it('accepts the clinical free-text fields', () => {
    expect(
      medicalHistorySchema.parse({
        comorbidities: ['Diabetes', 'Hypertension'],
        drugs: ['Tamoxifen 20mg daily', 'Calcium + Vitamin D'],
        familyHistory: 'Yes - breast cancer',
      })
    ).toEqual({
      comorbidities: ['Diabetes', 'Hypertension'],
      drugs: ['Tamoxifen 20mg daily', 'Calcium + Vitamin D'],
      familyHistory: 'Yes - breast cancer',
    });
  });

  it('rejects unknown keys', () => {
    expect(() => medicalHistorySchema.parse({ unexpected: true })).toThrow();
  });

  it('rejects wrong types', () => {
    expect(() => medicalHistorySchema.parse({ allergies: 'penicillin' })).toThrow();
    expect(() => medicalHistorySchema.parse({ drugs: 'Tamoxifen' })).toThrow();
    expect(() => medicalHistorySchema.parse({ comorbidities: 'Diabetes' })).toThrow();
  });

  it('accepts an empty object', () => {
    expect(medicalHistorySchema.parse({})).toEqual({});
  });
});
