"""
Tests for the parts that run without torch / model weights:
the contract mapping, the mock, and the pipeline's keyword helpers.

Run:  cd ai && python -m pytest service/test_service.py -q
(The real model inference in pipeline.run_turn is covered by GPU smoke tests,
not here — it needs the weights.)
"""

from __future__ import annotations

from fastapi.testclient import TestClient

from service import pipeline as p
from service.mapping import derive_crisis, map_emotion, map_intent, map_risk_level


# ── mapping (contract enums) ───────────────────────────────────────────────


def test_risk_thresholds():
    assert map_risk_level(0.10, False) == "LOW"
    assert map_risk_level(0.60, False) == "MEDIUM"
    assert map_risk_level(0.80, False) == "HIGH"
    assert map_risk_level(0.90, False) == "CRITICAL"
    assert map_risk_level(0.10, True) == "CRITICAL"  # keyword forces CRITICAL


def test_derive_crisis():
    assert derive_crisis("CRITICAL", True) == (True, "direct")
    assert derive_crisis("HIGH", False) == (True, "indirect")
    assert derive_crisis("LOW", False) == (False, None)


def test_intent_and_emotion_mapping():
    assert map_intent("food") == "food_query"
    assert map_intent("coping") == "emotional_support"
    assert map_intent("crisis") == "crisis"
    assert map_intent("small_talk") == "small_talk"
    e = map_emotion("depression", 0.77)
    assert e.label == "sadness" and e.confidence == 0.77
    assert map_emotion("normal", 2.0).confidence == 1.0  # clamped


# ── pipeline keyword helpers (no models) ───────────────────────────────────


def test_intent_routing_en():
    assert p.detect_intent("what food should I eat during chemo") == "food"
    assert p.detect_intent("how to do breathing exercises") == "coping"  # not 'food'
    assert p.detect_intent("I want to die") == "crisis"
    assert p.detect_intent("hi") == "small_talk"
    assert p.detect_intent("I feel tired today") == "support"


def test_intent_routing_ar():
    assert p.detect_intent("ايه الاكل المناسب في الكيماوي") == "food"  # attached ال
    assert p.detect_intent("عايزة اتعلم تمارين تنفس") == "coping"
    assert p.detect_intent("نفسي اموت") == "crisis"  # hamza-normalized


def test_safety_filters():
    assert p._check("I want to kill myself", p.CRISIS_KEYWORDS)[0] is True
    assert p._check("take 50 mg sertraline daily", p.DRUG_KEYWORDS)[0] is True
    assert p._check("breathing", p.DRUG_KEYWORDS)[0] is False  # no 'eat'/word false-pos
    assert p.clean_response("### Therapist: hello   there</s>") == "hello there"


# ── mock mode through the app ──────────────────────────────────────────────


def _client(monkeypatch):
    monkeypatch.setenv("BAHYA_AI_MODE", "mock")
    monkeypatch.setenv("BAHYA_AI_API_KEY", "dev")
    import importlib

    import service.main as main

    importlib.reload(main)
    return TestClient(main.app)


def _body(message: str) -> dict:
    return {
        "version": 1,
        "sessionId": "s1",
        "message": message,
        "langHint": "en",
        "patient": {"patientId": "p1"},
        "history": [],
    }


def test_mock_auth_and_responses(monkeypatch):
    with _client(monkeypatch) as c:
        assert c.get("/health").json()["mode"] == "mock"
        assert c.post("/infer", json=_body("hi")).status_code == 401  # no bearer
        h = {"Authorization": "Bearer dev"}
        normal = c.post("/infer", json=_body("I feel sad"), headers=h).json()
        assert normal["riskLevel"] == "LOW" and normal["crisis"] is False
        crisis = c.post("/infer", json=_body("TEST_CRISIS"), headers=h).json()
        assert crisis["riskLevel"] == "CRITICAL" and crisis["crisisSignalType"] == "direct"
