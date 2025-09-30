# app/Dockerfile
FROM node:20-alpine3.20
WORKDIR /usr/src/app

# Apply OS security patches (shrinks Trivy OS CVEs)
RUN apk update && apk upgrade --no-cache

# Install prod deps only (deterministic via lockfile)
COPY package*.json ./
RUN npm ci --omit=dev

# Copy the rest of the app
COPY . .

EXPOSE 8080
CMD ["node", "index.js"]
