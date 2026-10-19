FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:8.0 AS builder
ARG TARGETARCH
ARG BUILD_CONFIGURATION=Release

WORKDIR /src/cart
COPY /pb/ ./pb
COPY /src/cart .

RUN dotnet restore "./src/cart.csproj" -r linux-musl-$TARGETARCH
RUN dotnet build "./src/cart.csproj" -r linux-musl-$TARGETARCH -c $BUILD_CONFIGURATION -o /app/cart/build
RUN dotnet publish "./src/cart.csproj" -r linux-musl-$TARGETARCH -o /cart-exec --no-restore
    
#-----------------------------------------------------------------------------

FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine3.20 AS runtime
WORKDIR /app/cart

COPY --from=builder /cart-exec .

ENV DOTNET_HOSTBUILDER__RELOADCONFIGONCHANGE=false
EXPOSE ${CART_PORT}

RUN ls -la

ENTRYPOINT [ "./cart"]
