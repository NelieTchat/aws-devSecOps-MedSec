FROM public.ecr.aws/docker/library/node:18-alpine
WORKDIR /usr/src/app

# add this line
RUN apk add --no-cache curl

# copy node_modules and app...
COPY --from=base /usr/src/app/node_modules ./node_modules
COPY . .

RUN addgroup -S nodegrp && adduser -S nodeuser -G nodegrp
USER nodeuser
EXPOSE 8080
ENV NODE_ENV=production
CMD ["node", "index.js"]
