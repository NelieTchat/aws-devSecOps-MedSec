FROM node:20-alpine
WORKDIR /usr/src/app

# copy manifests first (ensures lockfile is used)
COPY package*.json ./
RUN npm ci --omit=dev

# then copy the app
COPY . .

EXPOSE 8080
CMD ["node", "index.js"]
