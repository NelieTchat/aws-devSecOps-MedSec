FROM public.ecr.aws/docker/library/node:18-alpine
WORKDIR /usr/src/app

RUN apk add --no-cache curl

COPY package*.json ./
RUN npm ci --only=production

COPY . .

RUN addgroup -S nodegrp && adduser -S nodeuser -G nodegrp
USER nodeuser

EXPOSE 8080
ENV NODE_ENV=production
CMD ["node", "index.js"]
