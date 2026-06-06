-- CreateEnum
CREATE TYPE "FormScoringType" AS ENUM ('SUM', 'MANUAL');

-- CreateEnum
CREATE TYPE "FormInterpretationMode" AS ENUM ('RANGE', 'MANUAL', 'NONE');

-- CreateEnum
CREATE TYPE "FormVersionStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "FormQuestionType" AS ENUM ('SINGLE_SELECT', 'MULTI_SELECT', 'SCALE');

-- CreateEnum
CREATE TYPE "FormAssignmentTarget" AS ENUM ('SINGLE_PATIENT', 'ALL_PATIENTS', 'VOLUNTEER_FOR_PATIENT');

-- CreateEnum
CREATE TYPE "FormAssignmentStatus" AS ENUM ('SCHEDULED', 'PUBLISHED', 'SUBMITTED', 'REVIEWED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "AssessmentStatus" AS ENUM ('NORMAL', 'MILD', 'MODERATE', 'SEVERE', 'CRITICAL');

-- CreateTable
CREATE TABLE "FormTemplate" (
    "id" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "category" TEXT,
    "scoringType" "FormScoringType" NOT NULL DEFAULT 'SUM',
    "interpretationMode" "FormInterpretationMode" NOT NULL DEFAULT 'RANGE',
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "currentVersionId" TEXT,
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FormTemplate_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FormVersion" (
    "id" TEXT NOT NULL,
    "templateId" TEXT NOT NULL,
    "version" INTEGER NOT NULL,
    "status" "FormVersionStatus" NOT NULL DEFAULT 'DRAFT',
    "publishedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FormVersion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FormQuestion" (
    "id" TEXT NOT NULL,
    "versionId" TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    "text" TEXT NOT NULL,
    "type" "FormQuestionType" NOT NULL,
    "subscale" TEXT,
    "required" BOOLEAN NOT NULL DEFAULT true,
    "scaleMin" INTEGER,
    "scaleMax" INTEGER,
    "scaleStep" INTEGER,

    CONSTRAINT "FormQuestion_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FormAnswerChoice" (
    "id" TEXT NOT NULL,
    "questionId" TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    "label" TEXT NOT NULL,
    "score" INTEGER NOT NULL,

    CONSTRAINT "FormAnswerChoice_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FormScoreRange" (
    "id" TEXT NOT NULL,
    "versionId" TEXT NOT NULL,
    "subscale" TEXT,
    "label" TEXT NOT NULL,
    "minScore" INTEGER NOT NULL,
    "maxScore" INTEGER NOT NULL,
    "note" TEXT,

    CONSTRAINT "FormScoreRange_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FormAssignment" (
    "id" TEXT NOT NULL,
    "templateId" TEXT NOT NULL,
    "formVersionId" TEXT NOT NULL,
    "patientId" TEXT NOT NULL,
    "assignedToUserId" TEXT,
    "assignedById" TEXT NOT NULL,
    "target" "FormAssignmentTarget" NOT NULL,
    "status" "FormAssignmentStatus" NOT NULL DEFAULT 'PUBLISHED',
    "publishAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FormAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FormSubmission" (
    "id" TEXT NOT NULL,
    "assignmentId" TEXT NOT NULL,
    "formVersionId" TEXT NOT NULL,
    "patientId" TEXT NOT NULL,
    "submittedByUserId" TEXT NOT NULL,
    "answers" JSONB NOT NULL,
    "totalScore" INTEGER,
    "subscaleScores" JSONB,
    "interpretation" JSONB,
    "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FormSubmission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Assessment" (
    "id" TEXT NOT NULL,
    "patientId" TEXT NOT NULL,
    "doctorId" TEXT NOT NULL,
    "submissionId" TEXT,
    "templateKey" TEXT NOT NULL,
    "score" INTEGER,
    "status" "AssessmentStatus" NOT NULL,
    "doctorNote" TEXT,
    "reviewedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Assessment_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "FormTemplate_key_key" ON "FormTemplate"("key");

-- CreateIndex
CREATE UNIQUE INDEX "FormTemplate_currentVersionId_key" ON "FormTemplate"("currentVersionId");

-- CreateIndex
CREATE INDEX "FormTemplate_category_idx" ON "FormTemplate"("category");

-- CreateIndex
CREATE INDEX "FormTemplate_isActive_idx" ON "FormTemplate"("isActive");

-- CreateIndex
CREATE INDEX "FormTemplate_isDefault_idx" ON "FormTemplate"("isDefault");

-- CreateIndex
CREATE INDEX "FormVersion_status_idx" ON "FormVersion"("status");

-- CreateIndex
CREATE UNIQUE INDEX "FormVersion_templateId_version_key" ON "FormVersion"("templateId", "version");

-- CreateIndex
CREATE INDEX "FormQuestion_versionId_idx" ON "FormQuestion"("versionId");

-- CreateIndex
CREATE INDEX "FormAnswerChoice_questionId_idx" ON "FormAnswerChoice"("questionId");

-- CreateIndex
CREATE INDEX "FormScoreRange_versionId_idx" ON "FormScoreRange"("versionId");

-- CreateIndex
CREATE INDEX "FormScoreRange_versionId_subscale_idx" ON "FormScoreRange"("versionId", "subscale");

-- CreateIndex
CREATE INDEX "FormAssignment_patientId_status_idx" ON "FormAssignment"("patientId", "status");

-- CreateIndex
CREATE INDEX "FormAssignment_assignedToUserId_status_idx" ON "FormAssignment"("assignedToUserId", "status");

-- CreateIndex
CREATE INDEX "FormAssignment_status_publishAt_idx" ON "FormAssignment"("status", "publishAt");

-- CreateIndex
CREATE INDEX "FormAssignment_templateId_idx" ON "FormAssignment"("templateId");

-- CreateIndex
CREATE INDEX "FormAssignment_formVersionId_idx" ON "FormAssignment"("formVersionId");

-- CreateIndex
CREATE UNIQUE INDEX "FormSubmission_assignmentId_key" ON "FormSubmission"("assignmentId");

-- CreateIndex
CREATE INDEX "FormSubmission_patientId_submittedAt_idx" ON "FormSubmission"("patientId", "submittedAt");

-- CreateIndex
CREATE INDEX "FormSubmission_formVersionId_idx" ON "FormSubmission"("formVersionId");

-- CreateIndex
CREATE UNIQUE INDEX "Assessment_submissionId_key" ON "Assessment"("submissionId");

-- CreateIndex
CREATE INDEX "Assessment_patientId_createdAt_idx" ON "Assessment"("patientId", "createdAt");

-- CreateIndex
CREATE INDEX "Assessment_doctorId_idx" ON "Assessment"("doctorId");

-- AddForeignKey
ALTER TABLE "FormTemplate" ADD CONSTRAINT "FormTemplate_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormTemplate" ADD CONSTRAINT "FormTemplate_currentVersionId_fkey" FOREIGN KEY ("currentVersionId") REFERENCES "FormVersion"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormVersion" ADD CONSTRAINT "FormVersion_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "FormTemplate"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormQuestion" ADD CONSTRAINT "FormQuestion_versionId_fkey" FOREIGN KEY ("versionId") REFERENCES "FormVersion"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormAnswerChoice" ADD CONSTRAINT "FormAnswerChoice_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "FormQuestion"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormScoreRange" ADD CONSTRAINT "FormScoreRange_versionId_fkey" FOREIGN KEY ("versionId") REFERENCES "FormVersion"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormAssignment" ADD CONSTRAINT "FormAssignment_templateId_fkey" FOREIGN KEY ("templateId") REFERENCES "FormTemplate"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormAssignment" ADD CONSTRAINT "FormAssignment_formVersionId_fkey" FOREIGN KEY ("formVersionId") REFERENCES "FormVersion"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormAssignment" ADD CONSTRAINT "FormAssignment_patientId_fkey" FOREIGN KEY ("patientId") REFERENCES "Patient"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormAssignment" ADD CONSTRAINT "FormAssignment_assignedToUserId_fkey" FOREIGN KEY ("assignedToUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormAssignment" ADD CONSTRAINT "FormAssignment_assignedById_fkey" FOREIGN KEY ("assignedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormSubmission" ADD CONSTRAINT "FormSubmission_assignmentId_fkey" FOREIGN KEY ("assignmentId") REFERENCES "FormAssignment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormSubmission" ADD CONSTRAINT "FormSubmission_formVersionId_fkey" FOREIGN KEY ("formVersionId") REFERENCES "FormVersion"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormSubmission" ADD CONSTRAINT "FormSubmission_patientId_fkey" FOREIGN KEY ("patientId") REFERENCES "Patient"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormSubmission" ADD CONSTRAINT "FormSubmission_submittedByUserId_fkey" FOREIGN KEY ("submittedByUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assessment" ADD CONSTRAINT "Assessment_patientId_fkey" FOREIGN KEY ("patientId") REFERENCES "Patient"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assessment" ADD CONSTRAINT "Assessment_doctorId_fkey" FOREIGN KEY ("doctorId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Assessment" ADD CONSTRAINT "Assessment_submissionId_fkey" FOREIGN KEY ("submissionId") REFERENCES "FormSubmission"("id") ON DELETE SET NULL ON UPDATE CASCADE;
