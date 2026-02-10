# Custom Instructions for Claude Code

Build a production-ready Evolution API backend for Railway deployment that enables WhatsApp messaging integration.

## Project Overview
Create a Docker-based Evolution API setup optimized for Railway.app deployment. This will serve as a WhatsApp messaging backend that receives image URLs and captions, then sends them to specified WhatsApp groups.

## Technical Requirements

### 1. Docker Configuration
- Use the official Evolution API image: `atendai/evolution-api:latest`
- Configure for Railway's platform constraints
- Include persistent volume management for WhatsApp sessions
- Expose port 8080 for HTTP traffic

### 2. Environment Configuration
Create a `.env` file with these variables:
- `AUTHENTICATION_API_KEY` - Secure API key for authentication
- `SERVER_URL` - Dynamic Railway deployment URL
- `SERVER_PORT` - 8080
- `DATABASE_ENABLED` - false (to reduce resource usage)
- `LOG_LEVEL` - ERROR (minimize logging overhead)
- `INSTANCE_MAX` - 1 (single WhatsApp instance)
- `STORE_MESSAGES` - false (reduce storage)
- `STORE_CONTACTS` - false (reduce storage)

### 3. Railway-Specific Optimizations
- Minimize RAM usage (target: <400MB)
- Configure for Railway's ephemeral filesystem
- Use Railway's persistent volumes for session data
- Optimize for Railway's $5 free tier limits (0.5GB RAM, 1 vCPU)

### 4. Required Files Structure
```
evolution-api-backend/
├── Dockerfile (if custom build needed)
├── docker-compose.yml (for local testing)
├── railway.json (Railway deployment config)
├── .env.example (template for environment variables)
├── README.md (deployment instructions)
└── scripts/
    └── healthcheck.sh (optional health monitoring)
```

### 5. API Endpoints to Support
The deployed API must support:
- `POST /instance/create` - Create WhatsApp instance
- `GET /instance/connect/:instanceName` - Get QR code
- `GET /group/fetchAllGroups/:instanceName` - List WhatsApp groups
- `POST /message/sendMedia/:instanceName` - Send image with caption
- `GET /instance/connectionState/:instanceName` - Check connection status

### 6. Docker Compose Configuration
Create a production-ready docker-compose.yml with:
- Named volumes for persistence
- Restart policies
- Resource limits (512MB RAM max)
- Health checks
- Network configuration

### 7. Railway Deployment Configuration
Create railway.json with:
- Build configuration (Docker)
- Port mapping (8080)
- Health check endpoint
- Environment variable placeholders
- Volume mount specifications

### 8. Security Measures
- Generate secure random API key by default
- Add rate limiting considerations
- Include CORS configuration
- Secure webhook endpoints

### 9. Documentation Requirements
Create comprehensive README.md including:
- Railway one-click deploy button
- Manual deployment steps
- Environment variable descriptions
- API endpoint examples with curl commands
- Troubleshooting common issues
- Cost estimates for Railway free tier

### 10. Testing Configuration
Provide test scripts for:
- Verifying deployment health
- Testing QR code generation
- Testing message sending
- Checking WhatsApp connection status

## Key Constraints
- Must run within Railway's free tier limits (0.5GB RAM, 1 vCPU)
- Must maintain WhatsApp connection across container restarts
- Must handle Railway's deployment URL dynamically
- Should minimize storage usage (<500MB)

## Expected Deliverables
1. Complete project structure with all configuration files
2. Railway-optimized docker-compose.yml
3. railway.json deployment configuration
4. Comprehensive .env.example with all variables
5. Detailed README.md with deployment instructions
6. Test scripts for validation
7. One-click Railway deploy button configuration

## Success Criteria
- Deploys successfully to Railway in <5 minutes
- Maintains WhatsApp connection after deployment
- Uses <400MB RAM under normal operation
- Can send images to WhatsApp groups via API
- Persists session data across restarts
- Stays within Railway free tier limits

## Additional Context
This backend will integrate with:
- n8n workflow automation (receives webhooks)
- Bannerbear (image generation service)
- OpenAI (caption generation)

The typical flow: Bannerbear generates image → n8n receives webhook → n8n calls OpenAI for caption → n8n sends to this Evolution API → WhatsApp group receives message.

Build this with production reliability in mind while optimizing for Railway's free tier resource constraints.