# Evolution API — Railway Deployment

Production-ready [Evolution API](https://github.com/EvolutionAPI/evolution-api) backend optimized for [Railway.app](https://railway.app) deployment. Enables WhatsApp messaging via a simple REST API.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/new?template=https://github.com/zarusirig/evolution-api-railway)


---

## Quick Start (Railway)

### 1. One-Click Deploy
Click the **Deploy on Railway** button above, or manually:

1. Create a new project on [Railway](https://railway.app)
2. Add a **PostgreSQL** database service (required)
3. Add a new service → **Deploy from GitHub Repo** → select this repo
4. Add these environment variables to the Evolution API service:

| Variable | Value | Notes |
|---|---|---|
| `SERVER_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Railway auto-generates this |
| `SERVER_PORT` | `8080` | Fixed |
| `AUTHENTICATION_API_KEY` | *(generate one)* | `openssl rand -hex 16` |
| `DATABASE_PROVIDER` | `postgresql` | Required |
| `DATABASE_CONNECTION_URI` | `${{Postgres.DATABASE_URL}}` | Reference the Railway Postgres service |
| `LOG_LEVEL` | `ERROR,WARN` | Minimize overhead |
| `CACHE_LOCAL_ENABLED` | `true` | Use local cache (no Redis needed) |
| `CACHE_REDIS_ENABLED` | `false` | Save RAM |
| `TELEMETRY_ENABLED` | `false` | Optional |

5. Deploy — the service will be live in ~2–3 minutes

### 2. Connect WhatsApp
```bash
# Set your variables
BASE_URL="https://your-app.up.railway.app"
API_KEY="your-api-key"

# Create an instance
curl -X POST "${BASE_URL}/instance/create" \
  -H "Content-Type: application/json" \
  -H "apikey: ${API_KEY}" \
  -d '{
    "instanceName": "main",
    "integration": "WHATSAPP-BAILEYS",
    "qrcode": true
  }'

# Get QR code (scan with WhatsApp)
curl -X GET "${BASE_URL}/instance/connect/main" \
  -H "apikey: ${API_KEY}"
```

---

## API Reference

All requests require the `apikey` header:
```
apikey: YOUR_AUTHENTICATION_API_KEY
```

### Create Instance
```bash
curl -X POST "${BASE_URL}/instance/create" \
  -H "Content-Type: application/json" \
  -H "apikey: ${API_KEY}" \
  -d '{
    "instanceName": "main",
    "integration": "WHATSAPP-BAILEYS",
    "qrcode": true
  }'
```

### Get QR Code
```bash
curl -X GET "${BASE_URL}/instance/connect/main" \
  -H "apikey: ${API_KEY}"
```

### Check Connection Status
```bash
curl -X GET "${BASE_URL}/instance/connectionState/main" \
  -H "apikey: ${API_KEY}"
```

### List WhatsApp Groups
```bash
curl -X GET "${BASE_URL}/group/fetchAllGroups/main?getParticipants=false" \
  -H "apikey: ${API_KEY}"
```

### Send Image to Group
```bash
curl -X POST "${BASE_URL}/message/sendMedia/main" \
  -H "Content-Type: application/json" \
  -H "apikey: ${API_KEY}" \
  -d '{
    "number": "120363XXXXXXXXXX@g.us",
    "mediatype": "image",
    "media": "https://example.com/image.png",
    "caption": "Hello from Evolution API!",
    "mimetype": "image/png",
    "fileName": "image.png"
  }'
```

---

## Local Development

### Prerequisites
- Docker & Docker Compose

### Run Locally
```bash
# Copy and configure environment
cp .env.example .env
# Edit .env — at minimum set AUTHENTICATION_API_KEY

# Start services (PostgreSQL + Evolution API)
docker compose up -d

# Check logs
docker compose logs -f evolution-api

# Health check
curl http://localhost:8080/ping
```

### Stop
```bash
docker compose down        # Stop services (keep data)
docker compose down -v     # Stop and remove volumes
```

---

## Project Structure

```
├── Dockerfile              # Railway-optimized (uses pre-built image)
├── docker-compose.yml      # Local dev with PostgreSQL
├── railway.json            # Railway deployment configuration
├── .env.example            # Environment variable template
├── README.md               # This file
├── plan.md                 # Original project plan
└── scripts/
    ├── healthcheck.sh      # Simple health check script
    └── test-deployment.sh  # Full API endpoint test suite
```

---

## Test Scripts

### Health Check
```bash
./scripts/healthcheck.sh http://localhost:8080
```

### Full Deployment Test
```bash
chmod +x ./scripts/test-deployment.sh
./scripts/test-deployment.sh https://your-app.up.railway.app YOUR_API_KEY
```

---

## Railway Cost Estimate

| Resource | Free Tier Limit | Evolution API Usage |
|---|---|---|
| RAM | 512 MB | ~300–400 MB |
| vCPU | 1 core | ~0.2–0.5 core idle |
| Storage | 1 GB | ~100–200 MB |
| Bandwidth | 100 GB/mo | Minimal |
| Hours | 500 hrs/mo (~21 days) | Continuous if within limits |

> **Tip:** The $5 Hobby plan gives unlimited hours and 8 GB RAM — recommended for production use.

---

## Integration with n8n

This backend is designed to work with this flow:

```
Bannerbear (generates image)
    → n8n (receives webhook)
        → OpenAI (generates caption)
            → Evolution API (this service)
                → WhatsApp group (receives message)
```

In your n8n workflow, use an **HTTP Request** node to call:
- `POST /message/sendMedia/main` with the image URL and caption

---

## Troubleshooting

| Problem | Solution |
|---|---|
| API not starting | Check `DATABASE_CONNECTION_URI` — PostgreSQL must be reachable |
| QR code not appearing | Instance may already be connected. Check `/instance/connectionState/main` |
| Session lost after redeploy | Ensure Railway volume is mounted at `/evolution/store` and `/evolution/instances` |
| High memory usage | Set `DATABASE_SAVE_DATA_NEW_MESSAGE=false`, `CACHE_REDIS_ENABLED=false`, `LOG_LEVEL=ERROR,WARN` |
| 401 Unauthorized | Check that `apikey` header matches `AUTHENTICATION_API_KEY` |
| Cannot send to group | Use the group JID from `/group/fetchAllGroups/main` — format: `120363...@g.us` |

---

## Environment Variables Reference

See [`.env.example`](.env.example) for the full list with descriptions. Key variables:

| Variable | Required | Default | Description |
|---|---|---|---|
| `AUTHENTICATION_API_KEY` | ✅ | — | API key for all requests |
| `SERVER_URL` | ✅ | — | Public URL of this service |
| `DATABASE_CONNECTION_URI` | ✅ | — | PostgreSQL connection string |
| `DATABASE_PROVIDER` | ✅ | `postgresql` | Database type |
| `SERVER_PORT` | — | `8080` | HTTP port |
| `LOG_LEVEL` | — | `ERROR,WARN` | Log verbosity |
| `CACHE_LOCAL_ENABLED` | — | `true` | Local in-memory cache |
| `CACHE_REDIS_ENABLED` | — | `false` | Redis cache toggle |
| `TELEMETRY_ENABLED` | — | `false` | Anonymous telemetry |

---

## License

This project configuration is MIT licensed. Evolution API itself is licensed under the [Apache 2.0 License](https://github.com/EvolutionAPI/evolution-api/blob/main/LICENSE).
