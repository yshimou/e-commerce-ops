# E-Commerce Platform | DevOps & SRE Portfolio Project

A hands-on portfolio project focused on packaging, provisioning, and deploying
a distributed e-commerce application. It demonstrates an end-to-end path from
container images and Docker Compose to AWS infrastructure and Kubernetes.

> **Attribution:** The application and microservice source code come from the
> [OpenTelemetry Demo](https://github.com/open-telemetry/opentelemetry-demo).
> I did not write the application source. My work is focused on the
> containerization, orchestration, infrastructure, and deployment platform
> described below.

## Technology

- **Containers:** Docker, Dockerfiles, Docker Compose
- **Infrastructure as Code:** Terraform
- **Cloud:** AWS VPC, IAM, Amazon EKS, EC2
- **Orchestration:** Kubernetes, kind, `kubectl`
- **Ingress and traffic:** AWS Load Balancer Controller, Application Load Balancer
- **Application foundation:** OpenTelemetry Demo microservices

## Project highlights

| Area | Work delivered |
| --- | --- |
| **Containerization** | Authored most of the service Dockerfiles, covering the different languages and build approaches used by the demo. |
| **Local orchestration** | Created the Docker Compose configuration to build and run the multi-service application as an integrated stack. |
| **Infrastructure as Code** | Built Terraform configuration for the AWS VPC, public/private networking, routing, NAT, IAM roles, EKS control plane, and managed node groups. |
| **Kubernetes** | Wrote manifests for the application Deployments, Services, configuration, and service discovery. |
| **Local and cloud deployment** | Prepared the manifests for local testing on kind and deployment to Amazon EKS. |
| **Internet ingress** | Configured an AWS Load Balancer Controller Ingress path to provision an internet-facing Application Load Balancer for the frontend proxy. |

This work demonstrates practical DevOps/SRE skills in container builds,
multi-service orchestration, cloud networking, infrastructure as code,
Kubernetes operations, and internet-facing application delivery.

## Architecture at a glance

```text
Application source: OpenTelemetry Demo
                │
        Dockerfiles + Compose
          ┌─────┴──────┐
          │            │
    Local stack     Kubernetes
    Docker Compose   kind / EKS
                        │
                  AWS Load Balancer
                        │
                 Frontend proxy
                        │
                Frontend + services

Terraform provisions the AWS VPC and EKS foundation.
```

In Kubernetes, internal ClusterIP Services provide stable service discovery.
The `ecommerce-ops-demo-frontendproxy` Service is the application entry point.
On EKS, the `frontend-proxy` Ingress is configured for the AWS Load Balancer
Controller and an internet-facing ALB. Controller IAM/OIDC setup and ALB
subnet discovery prerequisites are documented in the [Kubernetes deployment
guide](./k8s/README.md).

## Run and deploy

### Docker Compose

Use the [official OpenTelemetry Demo Docker deployment guide](https://opentelemetry.io/docs/demo/docker_deployment/)
for the application workflow and configuration. This repository’s Compose
configuration is [`docker-compose.yml`](./docker-compose.yml).

### Kubernetes

The [Kubernetes deployment guide](./k8s/README.md) covers:

- Running the manifests locally on kind.
- Provisioning the AWS EKS foundation with Terraform.
- Preparing the AWS Load Balancer Controller and deploying the app to EKS.
- Exposing the frontend through an internet-facing ALB.

The AWS infrastructure configuration and architecture are also documented in
[`infra/README.md`](./infra/README.md).

## Upstream project and credits
The [OpenTelemetry Demo](https://github.com/open-telemetry/opentelemetry-demo)
is an open-source, community-maintained application created to demonstrate
OpenTelemetry instrumentation and observability in a realistic
microservice-based system. The application code, service behavior, and
instrumentation originate from that project and its contributors.

- [Official OpenTelemetry Demo documentation](https://opentelemetry.io/docs/demo/)
- [Docker deployment documentation](https://opentelemetry.io/docs/demo/docker_deployment/)
- [Kubernetes deployment documentation](https://opentelemetry.io/docs/demo/kubernetes_deployment/)
- [Forking guidance](https://opentelemetry.io/docs/demo/forking/)
- [Upstream source repository](https://github.com/open-telemetry/opentelemetry-demo)
- [Upstream contributors](https://github.com/open-telemetry/opentelemetry-demo/graphs/contributors)
- [Upstream license](https://github.com/open-telemetry/opentelemetry-demo/blob/main/LICENSE)

This repository is an independent portfolio adaptation. Credit for the
application and upstream source code belongs to the OpenTelemetry Demo
maintainers and contributors; the infrastructure and deployment work
highlighted here is my contribution.
