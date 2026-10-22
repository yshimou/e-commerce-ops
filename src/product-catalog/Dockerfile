FROM golang:1.22-alpine AS builder
WORKDIR /src/product-catalog
COPY . .
RUN go mod download && go build -o product-catalog . 

#-----------------------------------------------------------------------------
FROM alpine AS runtime
WORKDIR /app/product-catalog
COPY --from=builder /src/product-catalog/product-catalog .
COPY ./products/ ./products/
ENV PRODUCT_CATALOG_PORT=8088
ENTRYPOINT ["./product-catalog"]