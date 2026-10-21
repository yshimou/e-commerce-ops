# Fraud Detection Service

This service receives new orders by a Kafka topic and returns cases which are
suspected of fraud.

## Local Build

To build the protos and the service binary, run from the repo root:

```sh
cp -r ../../pb/ src/main/proto/
./gradlew shadowJar
```

## Docker Build

To build using Docker run from the repo root:

```sh
docker build --build-arg OTEL_JAVA_AGENT_VERSION=2.32.0 -f src/fraud-detection/Dockerfile .
```
