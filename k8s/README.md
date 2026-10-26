# Kubernetes Demo

This folder contains Kubernetes manifests for running the e-commerce demo on a
local cluster. It demonstrates containerized microservices, Deployments,
Services, service discovery, and application configuration.

## Architecture

The application is split into Kubernetes Deployments for the frontend, frontend
proxy, and supporting services such as the product catalogue, cart, and payment
service. ClusterIP Services provide stable in-cluster addresses for
service-to-service communication.

The app is reachable through the `ecommerce-ops-demo-frontendproxy` Service,
which routes requests to the frontend. For local access, forward that Service
to a port on your machine and browse to `http://localhost:8081`.

The frontend proxy manifest also includes an AWS Application Load Balancer
Ingress for an AWS environment. Kind does not provide an ALB controller, so
use port-forwarding when running locally. This demo does not include an
OpenTelemetry Collector; telemetry-export errors are expected unless one is
deployed separately.

## Deploy locally with kind

### Prerequisites

- Docker running
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

Create a local Kubernetes cluster:

```bash
kind create cluster --name ecommerce-ops
```

Select the kind context and verify the cluster is available:

```bash
kubectl config use-context kind-ecommerce-ops
kubectl get nodes
```

Apply the manifests from the repository root:

```bash
kubectl apply -f k8s/microservices/
```

Wait for workloads to start:

```bash
kubectl get pods -w
```

In another terminal, forward the frontend proxy Service to local port `8081`
and open [http://localhost:8081](http://localhost:8081):

```bash
kubectl port-forward svc/ecommerce-ops-demo-frontendproxy 8081:8080
```

The port-forward command must remain running while you use the app. Choose a
different local port if `8081` is already in use.

## Cleanup

From the repository root, delete the resources deployed by these manifests:

```bash
kubectl delete -f k8s/microservices/
```

Then remove the local cluster:

```bash
kind delete cluster --name ecommerce-ops
```

## Scope

This is a learning and portfolio demo, not a production deployment. A
production setup would additionally require environment-specific ingress and
secrets management, resource and health policies, and a configured telemetry
backend. The AWS Terraform configuration lives separately under `infra/`.