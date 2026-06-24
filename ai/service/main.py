"""
Bahya AI service — FastAPI entrypoint.

Two modes, selected by BAHYA_AI_MODE:
  * "real" (default) — loads the ML pipeline once at startup (pipeline.py) and
    runs the full per-turn inference.
  * "mock"           — canned, contract-valid responses (mock.py); no models, no
    torch. Used to exercise the backend without a GPU / model weights.

Either way the wire shape is the frozen contract (doocs/CHATBOT_CONTRACT.md):
  - GET  /health  -> readiness (no auth; container healthcheck)
  - POST /infer   -> contract section 5 response (Bearer auth required)

Run mock:  BAHYA_AI_MODE=mock BAHYA_AI_API_KEY=dev uvicorn service.main:app --port 8000
Run real:  BAHYA_AI_API_KEY=dev uvicorn service.main:app --port 8000
"""

from __future__ import annotations

import logging
import os
from contextlib import asynccontextmanager
from typing import Callable

from fastapi import Depends, FastAPI, Header, HTTPException, status

from .schemas import InferRequest, InferResponse

logging.basicConfig(level=os.environ.get("LOG_LEVEL", "INFO").upper())
log = logging.getLogger("ai.service")

MODE = os.environ.get("BAHYA_AI_MODE", "real").lower()

# Populated at startup with the chosen inference function (real or mock).
_infer: Callable[[InferRequest], InferResponse] | None = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global _infer
    if MODE == "mock":
        from .mock import infer_mock

        _infer = infer_mock
        log.info("AI service started in MOCK mode")
    else:
        # Import lazily so mock mode never needs torch/transformers installed.
        from . import pipeline

        pipeline.load_models()
        _infer = pipeline.run_turn
        log.info("AI service started in REAL mode")
    yield
    _infer = None


app = FastAPI(title="Bahya AI Service", version="1.0.0", lifespan=lifespan)


def require_bearer(authorization: str | None = Header(default=None)) -> None:
    """Enforce `Authorization: Bearer ${BAHYA_AI_API_KEY}` (contract section 3)."""
    expected = os.environ.get("BAHYA_AI_API_KEY")
    if not expected:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="server_misconfigured",
        )
    if authorization != f"Bearer {expected}":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="unauthorized"
        )


@app.get("/health")
def health() -> dict[str, object]:
    # Ready once the inference function is wired (models loaded in real mode).
    ready = _infer is not None
    if MODE != "mock":
        try:
            from . import pipeline

            ready = ready and pipeline.is_ready()
        except Exception:  # noqa: BLE001
            ready = False
    return {"status": "ok" if ready else "loading", "mode": MODE}


@app.post("/infer", response_model=InferResponse)
def infer(req: InferRequest, _: None = Depends(require_bearer)) -> InferResponse:
    if _infer is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail="not_ready"
        )
    try:
        return _infer(req)
    except Exception:  # noqa: BLE001
        # Never leak PHI / stack traces in the body. The backend maps any
        # non-200 to its own 502 AI_INFERENCE_FAILED and keeps the patient msg.
        log.exception("inference failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="inference_failed"
        )
