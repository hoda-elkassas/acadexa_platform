# ==========================================
# Stage 1: Build dependencies
# ==========================================
FROM python:3.11-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install dependencies into a wheels directory
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt


# ==========================================
# Stage 2: Final runtime image
# ==========================================
FROM python:3.11-slim AS runtime

WORKDIR /app

# Install runtime dependencies (like curl for healthcheck)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy wheels from builder stage and install
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache-dir --no-index --find-links=/wheels -r requirements.txt

# Copy application source code
COPY . .

# Create uploads directory and appuser
RUN mkdir -p /app/temp_uploads && \
    groupadd -r appgroup && \
    useradd -r -g appgroup -u 1001 appuser && \
    chown -R appuser:appgroup /app

# Switch to non-root user for security
USER appuser

EXPOSE 8000

# Healthcheck to verify app status
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Start uvicorn with workers based on CPU count dynamically
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port 8000 --workers ${WORKERS:-$(nproc)}"]
