# app/Dockerfile
FROM node:20-alpine
WORKDIR /usr/src/app

# copy manifests first to leverage cache
COPY package*.json ./
RUN npm ci --omit=dev

# then copy the rest
COPY . .

EXPOSE 8080
CMD ["node", "index.js"]
