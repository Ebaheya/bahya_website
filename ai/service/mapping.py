"""
Pure mapping helpers: turn the ML pipeline's raw outputs (from
chatbot_integration_First.py) into the frozen contract enums
(doocs/CHATBOT_CONTRACT.md sections 5/6).

This module has NO heavy dependencies (no torch/transformers) so it can be unit
tested on its own and imported even in mock mode.
"""

from __future__ import annotations

from .schemas import CrisisSignalType, Emotion, Intent, RiskLevel

# Risk thresholds — mirror the script's constants (SECTION 1) plus a CRITICAL cut.
CRITICAL_THRESHOLD = 0.85
HIGH_THRESHOLD = 0.75  # script CRISIS_THRESHOLD
MEDIUM_THRESHOLD = 0.55  # script MEDIUM_THRESHOLD

# script intent ('crisis'|'food'|'coping'|'support') -> contract intent enum.
# `coping` (CBT/relaxation help) is support, not factual `medical_info`.
_INTENT_MAP: dict[str, Intent] = {
    "crisis": "crisis",
    "food": "food_query",
    "coping": "emotional_support",
    "support": "emotional_support",
    "small_talk": "small_talk",
}

# diagnose() primary_diagnosis (normal/depression/anxiety/stress) -> emotion label.
# emotion.label is a free string in the contract; these are sensible defaults.
_EMOTION_BY_DIAGNOSIS: dict[str, str] = {
    "normal": "neutral",
    "depression": "sadness",
    "anxiety": "anxiety",
    "stress": "stressed",
}


def map_intent(raw_intent: str) -> Intent:
    return _INTENT_MAP.get(raw_intent, "emotional_support")


def map_emotion(primary_diagnosis: str, confidence: float) -> Emotion:
    label = _EMOTION_BY_DIAGNOSIS.get((primary_diagnosis or "").lower(), "neutral")
    # Clamp confidence into the contract's 0..1 range defensively.
    conf = max(0.0, min(1.0, float(confidence)))
    return Emotion(label=label, confidence=round(conf, 4))


def map_risk_level(risk_score: float, is_crisis_keyword: bool) -> RiskLevel:
    """Score + explicit crisis keyword -> LOW/MEDIUM/HIGH/CRITICAL.

    A crisis keyword always forces CRITICAL; otherwise the score decides.
    """
    if is_crisis_keyword or risk_score > CRITICAL_THRESHOLD:
        return "CRITICAL"
    if risk_score > HIGH_THRESHOLD:
        return "HIGH"
    if risk_score > MEDIUM_THRESHOLD:
        return "MEDIUM"
    return "LOW"


def derive_crisis(
    risk_level: RiskLevel, is_crisis_keyword: bool
) -> tuple[bool, CrisisSignalType | None]:
    """Backend escalation inputs: `crisis` bool + `crisisSignalType`.

    - explicit crisis keyword  -> direct  (immediate call-center escalation)
    - HIGH/CRITICAL by score    -> indirect
    - otherwise                 -> not a crisis
    """
    if is_crisis_keyword:
        return True, "direct"
    if risk_level in ("HIGH", "CRITICAL"):
        return True, "indirect"
    return False, None
