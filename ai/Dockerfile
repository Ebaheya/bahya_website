# Real pipeline image (BAHYA_AI_MODE=real). Uses a CUDA-enabled PyTorch base so
# the GPU is available at runtime (host needs the NVIDIA Container Toolkit and
# the `deploy.resources.reservations.devices` block in docker-compose.prod.yml).
#
# For a lightweight MOCK image instead, build with:
#   docker build -f Dockerfile.mock -t bahya-ai:mock ai     (see Dockerfile.mock)
FROM pytorch/pytorch:2.4.1-cuda12.1-cudnn9-runtime

WORKDIR /app

# System deps some wheels need (fasttext build, sentence-transformers).
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential git \
    && rm -rf /var/lib/apt/lists/*

COPY service/requirements.txt ./service/requirements.txt
RUN pip install --no-cache-dir -r service/requirements.txt

COPY service ./service

# Model weights + RAG store are mounted at runtime (not baked in). Point the
# pipeline at them via env (see service/pipeline.py): AR_DIAGNOSIS_MODEL,
# EN_SUPPORT_FINETUNE, RAG_STORE_PATH, ...  e.g. -v /srv/bahya/models:/models
ENV BAHYA_AI_MODE=real

EXPOSE 8000

# Single worker: the models are large; scale with replicas, not workers.
CMD ["uvicorn", "service.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
