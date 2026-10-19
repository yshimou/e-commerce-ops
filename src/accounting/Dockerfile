FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/sdk:8.0 AS builder
ARG TARGETARCH
ARG BUILD_CONFIGURATION=Release

WORKDIR /src/accounting
#As we need to copy the proto file from the parent directory, makes sure the repository root is the build context 
COPY /pb/demo.proto ./proto/demo.proto
COPY /src/accounting .


RUN dotnet restore "./Accounting.csproj" -r linux-$TARGETARCH
RUN dotnet build "./Accounting.csproj" -r linux-$TARGETARCH -c $BUILD_CONFIGURATION -o /app/build
RUN dotnet publish "./Accounting.csproj" -r linux-$TARGETARCH -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

#-----------------------------------------------------------------------------

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=builder /app/publish .

USER root
RUN mkdir -p "/var/log/opentelemetry/dotnet"
RUN chown app "/var/log/opentelemetry/dotnet"
RUN chown app "/app/instrument.sh"
USER app

ENTRYPOINT ["/app/instrument.sh", "dotnet", "Accounting.dll"]