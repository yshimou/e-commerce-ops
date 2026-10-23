FROM eclipse-temurin:21-jdk AS builder
WORKDIR /src/ad

COPY ./src/ad .
RUN ls -la
RUN ./gradlew downloadRepos && ./gradlew installDist -PprotoSourceDir=./pb

#-----------------------------------------------------------------------------
FROM eclipse-temurin:21-jre AS runtime
WORKDIR /app
COPY --from=builder /src/ad/ ./
ENV AD_PORT 9099

ENTRYPOINT ["./build/install/opentelemetry-demo-ad/bin/Ad"]