"""
Phase 0 mock inference — canned, contract-valid responses with no models.

Kept available behind BAHYA_AI_MODE=mock so the backend can be exercised
end-to-end on machines without a GPU or the model weights. The real pipeline
lives in pipeline.py (BAHYA_AI_MODE=real, the default).
"""

from __future__ import annotations

from .schemas import CONTRACT_VERSION, Emotion, InferRequest, InferResponse

# Agreed test hook (contract section 10): a message containing this token forces
# a CRITICAL/direct crisis so the backend's silent escalation can be verified.
CRISIS_TRIGGER = "TEST_CRISIS"


def _detect_lang(req: InferRequest) -> str:
    if req.langHint:
        return req.langHint
    return "ar" if any("؀" <= c <= "ۿ" for c in req.message) else "en"


def infer_mock(req: InferRequest) -> InferResponse:
    lang = _detect_lang(req)

    if CRISIS_TRIGGER in req.message:
        reply = (
            "أنا هنا معاكِ، مش لوحدك خالص."
            if lang == "ar"
            else "I hear you, and I'm right here with you. You are not alone."
        )
        return InferResponse(
            version=CONTRACT_VERSION,
            reply=reply,
            lang=lang,
            emotion=Emotion(label="sadness", confidence=0.9),
            intent="crisis",
            riskLevel="CRITICAL",
            crisisProbability=0.95,
            crisis=True,
            crisisSignalType="direct",
            flaggedPhrases=[CRISIS_TRIGGER],
            extra={"mock": True},
        )

    reply = (
        "شكراً لمشاركتك ده معايا. إزاي حاسة دلوقتي؟"
        if lang == "ar"
        else "Thank you for sharing that with me. How are you feeling right now?"
    )
    return InferResponse(
        version=CONTRACT_VERSION,
        reply=reply,
        lang=lang,
        emotion=Emotion(label="neutral", confidence=0.5),
        intent="emotional_support",
        riskLevel="LOW",
        crisisProbability=0.02,
        crisis=False,
        crisisSignalType=None,
        flaggedPhrases=[],
        extra={"mock": True},
    )
