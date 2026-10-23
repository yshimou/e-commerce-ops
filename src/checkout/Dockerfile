FROM golang:1.22-alpine AS builder

WORKDIR /src/checkout
COPY ./src/checkout .
RUN go mod download
RUN go build -ldflags "-s -w" -o checkout-exec/ 

#-----------------------------------------------------------------------------
FROM alpine AS runtime
WORKDIR /app/checkout
COPY --from=builder /src/checkout/checkout-exec .
EXPOSE ${CHECKOUT_PORT}
ENTRYPOINT ["./checkout"]