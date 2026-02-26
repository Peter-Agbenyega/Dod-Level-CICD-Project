# =============================================================================
# Multi-stage Dockerfile for DoD Tactical Operations Center Dashboard
# Stage 1: Build React frontend
# Stage 2: Production server with Node.js
# =============================================================================

# --- Stage 1: Build React client ---
FROM node:20-alpine AS client-build

WORKDIR /app/client

COPY client/package.json client/package-lock.json* ./
RUN npm ci --production=false

COPY client/ ./
RUN npm run build

# --- Stage 2: Production server ---
FROM node:20-alpine AS production

# Add non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Install server dependencies
COPY server/package.json server/package-lock.json* ./
RUN npm ci --production && npm cache clean --force

# Copy server source
COPY server/ ./

# Copy React build from Stage 1
COPY --from=client-build /app/client/build ./client/build

# Set environment
ENV NODE_ENV=production
ENV PORT=5000

# Use non-root user
USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/api/health || exit 1

CMD ["node", "server.js"]
