"""
Phase 0 mock inference — canned, contract-valid responses with no models.

Kept available behind BAHYA_AI_MODE=mock so the backend can be exercised
end-to-end on machines without a GPU or the model weights. The real pipeline
lives in pipeline.py (BAHYA_AI_MODE=real, the default).
"""

from __future__ import annotations

import random

from .schemas import CONTRACT_VERSION, Emotion, InferRequest, InferResponse

# Agreed test hook (contract section 10): a message containing this token forces
# a CRITICAL/direct crisis so the backend's silent escalation can be verified.
CRISIS_TRIGGER = "TEST_CRISIS"

# Pools of canned, contract-valid normal replies. One is picked at random per
# turn so the mock looks lifelike in demos. All stay riskLevel=LOW / crisis=False
# — only CRISIS_TRIGGER escalates, keeping the escalation test hook deterministic.
_NORMAL_REPLIES = {
    "ar": [
        "شكراً لمشاركتك ده معايا. إزاي حاسة دلوقتي؟",
        "أنا سامعاكِ، وكلامك مهم بالنسبة لي. تحبي تحكيلي أكتر؟",
        "خدي نفس عميق، إحنا ماشيين خطوة بخطوة مع بعض.",
        "حاسة إن النهاردة تقيل شوية؟ أنا هنا معاكِ في أي وقت.",
        "كل اللي بتحسي بيه طبيعي تماماً. عايزة نتكلم في إيه؟",
    ],
    "en": [
        "Thank you for sharing that with me. How are you feeling right now?",
        "I'm listening, and what you're saying matters. Tell me more?",
        "Let's take this one step at a time together. Take a deep breath.",
        "It sounds like today feels heavy. I'm right here whenever you need.",
        "Whatever you're feeling is completely valid. What's on your mind?",
    ],
}

# Light variety on the signals too, still well within the LOW / non-crisis band.
_NORMAL_EMOTIONS = ["neutral", "sadness", "fear", "joy"]
_NORMAL_INTENTS = ["emotional_support", "small_talk", "medical_info"]


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

    reply = random.choice(_NORMAL_REPLIES[lang])
    return InferResponse(
        version=CONTRACT_VERSION,
        reply=reply,
        lang=lang,
        emotion=Emotion(
            label=random.choice(_NORMAL_EMOTIONS),
            confidence=round(random.uniform(0.4, 0.8), 2),
        ),
        intent=random.choice(_NORMAL_INTENTS),
        riskLevel="LOW",
        crisisProbability=round(random.uniform(0.0, 0.1), 2),
        crisis=False,
        crisisSignalType=None,
        flaggedPhrases=[],
        extra={"mock": True},
    )
