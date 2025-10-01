FROM node:20-alpine3.20

# Create non-root user (uid/gid 1000)
RUN addgroup -S app && adduser -S app -G app

WORKDIR /usr/src/app

# Patch OS CVEs
RUN apk update && apk upgrade --no-cache

# Install prod deps only
COPY package*.json ./
RUN npm ci --omit=dev

# Copy app code
COPY . .

# Ensure ownership for non-root
RUN chown -R app:app /usr/src/app

# Drop root
USER app

# Container-level healthcheck (works with Alpine's busybox wget)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:8080/health >/dev/null 2>&1 || exit 1

EXPOSE 8080
CMD ["node","index.js"]
