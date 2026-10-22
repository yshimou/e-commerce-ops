FROM node:22-alpine AS builder
WORKDIR /src/payment
COPY ./src/payment/ .
RUN apk add --no-cache python3 make g++ && npm ci --omit=dev

#-----------------------------------------------------------------------------
FROM node:22-alpine AS runtime
WORKDIR /app/payment

COPY --from=builder /src/payment/node_modules ./node_modules
COPY ./src/payment/ ./
COPY ./pb/demo.proto ./

EXPOSE ${PAYMENT_PORT}
ENTRYPOINT npm run start