"""
Pydantic models for the Bahya backend <-> AI service contract.

These mirror doocs/CHATBOT_CONTRACT.md sections 4 (request) and 5 (response)
EXACTLY. The backend validates the response with a strict Zod schema
(backend/src/modules/chatbot/ai.client.ts); any renamed/missing field makes the
backend return 502, so do not change field names without bumping `version`.
"""

from __future__ import annotations

from typing import Any, Literal, Optional

from pydantic import BaseModel, Field

CONTRACT_VERSION = 1

Lang = Literal["ar", "en"]
RiskLevel = Literal["LOW", "MEDIUM", "HIGH", "CRITICAL"]
Intent = Literal[
    "emotional_support",
    "food_query",
    "medical_info",
    "crisis",
    "small_talk",
]
CrisisSignalType = Literal["indirect", "direct"]


# --- Request (Backend -> AI), contract section 4 ---------------------------


class PatientProfile(BaseModel):
    patientId: str
    age: Optional[int] = None
    languagePref: Optional[Lang] = None
    cancerStage: Optional[str] = None
    diseaseStatus: Optional[str] = None
    treatments: list[str] = Field(default_factory=list)
    dietNotes: Optional[str] = None
    riskFlagFromHistory: Optional[RiskLevel] = None


class HistoryTurn(BaseModel):
    sender: Literal["PATIENT", "BOT"]
    text: str
    emotion: Optional[str] = None
    riskLevel: Optional[RiskLevel] = None
    createdAt: str


class InferRequest(BaseModel):
    version: int
    sessionId: str
    message: str
    langHint: Optional[Lang] = None
    patient: PatientProfile
    history: list[HistoryTurn] = Field(default_factory=list)


# --- Response (AI -> Backend), contract section 5 --------------------------


class Emotion(BaseModel):
    label: str
    confidence: float


class InferResponse(BaseModel):
    version: int = CONTRACT_VERSION
    reply: str
    lang: Lang
    emotion: Optional[Emotion] = None
    intent: Intent
    riskLevel: RiskLevel
    crisisProbability: Optional[float] = None
    crisis: bool
    crisisSignalType: Optional[CrisisSignalType] = None
    flaggedPhrases: list[str] = Field(default_factory=list)
    phq9Score: Optional[int] = None
    extra: dict[str, Any] = Field(default_factory=dict)
