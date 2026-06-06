-- Add SELECTED_PATIENTS target so a form can be published to a chosen subset of patients.
ALTER TYPE "FormAssignmentTarget" ADD VALUE 'SELECTED_PATIENTS' AFTER 'ALL_PATIENTS';
