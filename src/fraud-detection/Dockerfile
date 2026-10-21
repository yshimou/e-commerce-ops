
FROM --platform=${BUILDPLATFORM} gradle:8-jdk17 AS builder

WORKDIR /src/fraud-detection

COPY ./src/fraud-detection/ ./
COPY ./pb/ ./src/main/proto/
RUN gradle shadowJar

# -----------------------------------------------------------------------------

FROM gcr.io/distroless/java17-debian11

ARG OTEL_JAVA_AGENT_VERSION
WORKDIR /app/fraud-detection

COPY --from=builder /src/fraud-detection/build/libs/fraud-detection-1.0-all.jar ./
ADD --chmod=644 https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v$OTEL_JAVA_AGENT_VERSION/opentelemetry-javaagent.jar /app/opentelemetry-javaagent.jar
ENV JAVA_TOOL_OPTIONS=-javaagent:/app/opentelemetry-javaagent.jar

ENTRYPOINT [ "java", "-jar", "fraud-detection-1.0-all.jar" ]
