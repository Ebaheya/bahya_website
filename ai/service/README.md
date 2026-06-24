# Bahya AI Service

FastAPI service that answers `POST /infer` for the backend chat gateway, following
the frozen contract in [`doocs/CHATBOT_CONTRACT.md`](../../doocs/CHATBOT_CONTRACT.md).

## Phase 0 — mock (current)

Returns canned, contract-valid responses so the whole backend chat flow can be
exercised before the real ML models are wired in.

- `GET /health` → `{"status":"ok"}` (no auth; used by the container healthcheck)
- `POST /infer` → contract §5 response, **requires** `Authorization: Bearer ${BAHYA_AI_API_KEY}`
  - normal message → `riskLevel: LOW`, `crisis: false`
  - message containing `TEST_CRISIS` → `riskLevel: CRITICAL`, `crisis: true`,
    `crisisSignalType: "direct"` (contract §10 test hook)

### Run locally

```bash
cd ai
pip install -r service/requirements.txt
BAHYA_AI_API_KEY=dev uvicorn service.main:app --port 8000
```

```bash
curl -s -X POST localhost:8000/infer \
  -H "Authorization: Bearer dev" -H "Content-Type: application/json" \
  -d '{"version":1,"sessionId":"s1","message":"I feel sad",
       "patient":{"patientId":"p1"},"history":[]}'
```

### Run via Docker

```bash
docker build -t bahya-ai:latest ai
docker run --rm -e BAHYA_AI_API_KEY=dev -p 8000:8000 bahya-ai:latest
```

In the prod stack it runs as the `ai` service in `docker-compose.prod.yml`; the
backend reaches it at `http://ai:8000` on the `bahya` network.

## Phase 1 — real pipeline

The full ML pipeline from `ai/chatbot_integration_First.py`, refactored to be
stateless and contract-shaped. Selected with `BAHYA_AI_MODE=real` (the default).

Files:
- `pipeline.py` — loads all models once at startup (`load_models`), then
  `run_turn(req)` does language id → intent → diagnosis → crisis check → RAG →
  generation → drug-safety guard, and maps the result to the contract.
  **Stateless** (uses `req.history`), **signals only** (no alerts/summaries/files).
- `mapping.py` — pure script-output → contract-enum mapping (risk thresholds,
  intent, emotion, crisis tier). No heavy deps.
- `main.py` — thin: a lifespan loads the chosen mode; `/infer` dispatches.

### Model assets (not in the repo)

`run_turn` needs these present; point at them via env (see `pipeline.py`):

| env var | default | what |
|---|---|---|
| `AR_DIAGNOSIS_MODEL` | `./final_marbert_model` | fine-tuned MARBERT |
| `EN_SUPPORT_FINETUNE` | `english_support_finetuned/best_checkpoint` | tanusrich PEFT |
| `RAG_STORE_PATH` | `rag_store` | ChromaDB store (build with `build_rag_store.py`) |
| `MAX_NEW_TOKENS` | `200` | generation length cap (latency knob) |

In prod, mount them as a volume (`ai_models:/models`) and set the env paths to
`/models/...` (already wired in `docker-compose.prod.yml`).

### Run real (GPU host with the weights)

```bash
docker build -t bahya-ai:latest ai          # CUDA base, full deps
docker run --rm --gpus all \
  -e BAHYA_AI_API_KEY=dev \
  -v /srv/bahya/models:/models \
  -e AR_DIAGNOSIS_MODEL=/models/final_marbert_model \
  -e EN_SUPPORT_FINETUNE=/models/english_support_finetuned/best_checkpoint \
  -e RAG_STORE_PATH=/models/rag_store \
  -p 8000:8000 bahya-ai:latest
```

`GET /health` reports `{"status":"loading"}` until the models finish loading,
then `{"status":"ok","mode":"real"}`. Raise `BAHYA_AI_TIMEOUT_MS` on the backend
to fit real generation latency (mock fits the 8 s default; real needs more).

### Tests

```bash
cd ai && python -m pytest service/test_service.py -q
```
Covers the contract mapping, the mock, and the keyword helpers — everything that
runs without the GPU/weights. Full `run_turn` inference is verified by a GPU
smoke test, not here.

See [`specs/009-chatbot-ai-gateway/AI_SERVICE_PLAN.md`](../../specs/009-chatbot-ai-gateway/AI_SERVICE_PLAN.md)
for the overall phasing.
