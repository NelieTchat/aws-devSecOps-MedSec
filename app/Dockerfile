FROM public.ecr.aws/docker/library/node:18-alpine
WORKDIR /usr/src/app

# Healthcheck needs curl
RUN apk add --no-cache curl

# Install dependencies (lockfile-friendly)
COPY package*.json ./
RUN npm ci --only=production

# Copy app
COPY . .

# Run as non-root
RUN addgroup -S nodegrp && adduser -S nodeuser -G nodegrp
USER nodeuser

EXPOSE 8080
ENV NODE_ENV=production
CMD ["node", "index.js"]
