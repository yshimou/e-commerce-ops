FROM node:20 AS builder
WORKDIR /src/flagd-ui
COPY . .
RUN npm ci && npm run build
#-----------------------------------------------------------------------------

FROM node:20-alpine AS runtime
WORKDIR /app/flagd-ui

COPY package*.json ./
RUN npm ci 

COPY src/instrumentation.ts ./instrumentation.ts
COPY ./next.config.mjs ./next.config.mjs
COPY --from=builder /src/flagd-ui/.next ./.next

EXPOSE 4000

ENTRYPOINT npm start