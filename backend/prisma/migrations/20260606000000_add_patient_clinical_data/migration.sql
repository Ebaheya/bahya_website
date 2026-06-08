-- CreateEnum
CREATE TYPE "MenopausalStatus" AS ENUM ('PRE_MENOPAUSAL', 'PERI_MENOPAUSAL', 'POST_MENOPAUSAL');

-- CreateEnum
CREATE TYPE "CancerStage" AS ENUM ('STAGE_0', 'STAGE_I', 'STAGE_II', 'STAGE_III', 'STAGE_IV');

-- CreateEnum
CREATE TYPE "DiseaseStatus" AS ENUM ('NEWLY_DIAGNOSED', 'ACTIVE_TREATMENT', 'FOLLOW_UP', 'RECURRENCE', 'METASTATIC');

-- CreateEnum
CREATE TYPE "TumorBiology" AS ENUM ('LUMINAL_A', 'LUMINAL_B', 'HER2_ENRICHED', 'TNBC');

-- CreateEnum
CREATE TYPE "SurgeryType" AS ENUM ('NONE', 'BREAST_CONSERVATIVE', 'MASTECTOMY');

-- CreateEnum
CREATE TYPE "ChemotherapyType" AS ENUM ('NO', 'NEOADJUVANT', 'ADJUVANT', 'METASTATIC');

-- AlterTable
ALTER TABLE "Patient"
    ADD COLUMN "crn" TEXT,
    ADD COLUMN "bmi" DOUBLE PRECISION,
    ADD COLUMN "menopausalStatus" "MenopausalStatus",
    ADD COLUMN "dateOfDiagnosis" TIMESTAMP(3),
    ADD COLUMN "stageAtDiagnosis" "CancerStage",
    ADD COLUMN "diseaseStatus" "DiseaseStatus",
    ADD COLUMN "tumorBiology" "TumorBiology",
    ADD COLUMN "surgery" "SurgeryType",
    ADD COLUMN "chemotherapy" "ChemotherapyType",
    ADD COLUMN "radiotherapy" BOOLEAN,
    ADD COLUMN "hormonalTherapy" BOOLEAN,
    ADD COLUMN "targetedTherapy" BOOLEAN,
    ADD COLUMN "immunotherapy" BOOLEAN;

-- CreateIndex
CREATE UNIQUE INDEX "Patient_crn_key" ON "Patient"("crn");

-- CreateIndex
CREATE INDEX "Patient_diseaseStatus_idx" ON "Patient"("diseaseStatus");

-- CreateIndex
CREATE INDEX "Patient_tumorBiology_idx" ON "Patient"("tumorBiology");

-- CreateIndex
CREATE INDEX "Patient_surgery_idx" ON "Patient"("surgery");

-- CreateIndex
CREATE INDEX "Patient_chemotherapy_idx" ON "Patient"("chemotherapy");
