# ============================================================
# Evolution API — Railway-optimized Dockerfile
# Uses the official pre-built image to avoid RAM-heavy builds
# ============================================================
FROM atendai/evolution-api:latest

# Railway injects PORT; Evolution API listens on SERVER_PORT
ENV SERVER_PORT=8080

EXPOSE 8080

# Health check — the API responds with 200 on the root endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD wget -qO- http://localhost:8080/ || exit 1
