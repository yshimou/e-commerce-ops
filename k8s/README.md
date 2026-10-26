# E-Commerce Demo on Kubernetes

This project demonstrates deploying a microservice-based e-commerce
application to Kubernetes. Use kind for a cost-free local workflow, or deploy
the same application manifests to Amazon EKS and expose the frontend through an
AWS Application Load Balancer.

## Architecture

The application is split into Kubernetes Deployments for the frontend proxy,
frontend, and supporting services such as the product catalogue, cart, and
payment service. ClusterIP Services provide stable in-cluster addresses for
service-to-service communication.

The `ecommerce-ops-demo-frontendproxy` Service is the entry point to the app.
Locally, use `kubectl port-forward`. On EKS, the `frontend-proxy` Ingress asks
the AWS Load Balancer Controller to create an internet-facing ALB and route
traffic to the frontend proxy:

```text
Local:  browser → port-forward → frontend proxy Service → app
AWS:    internet → ALB → frontend proxy Service → app
```

## 1. Deploy locally with kind

### Prerequisites

- Docker running
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

Create the local cluster and switch to its kubectl context:

```bash
kind create cluster --name ecommerce-ops
kubectl config use-context kind-ecommerce-ops
kubectl get nodes
```

From the repository root, deploy the application manifests:

```bash
kubectl apply -f k8s/microservices/
kubectl get pods -w
```

Kind does not include the AWS Load Balancer Controller, so the Ingress in this
folder will not create a public endpoint locally. Access the app through the
frontend proxy Service instead. In another terminal, run:

```bash
kubectl port-forward svc/ecommerce-ops-demo-frontendproxy 8081:8080
```

Open [http://localhost:8081](http://localhost:8081). Keep the port-forward
running while using the app; choose a different local port if `8081` is busy.

### Clean up the local deployment

From the repository root:

```bash
kubectl delete -f k8s/microservices/
kind delete cluster --name ecommerce-ops
```

## 2. Deploy to AWS EKS

### Prerequisites

- AWS CLI, Terraform, `kubectl`, Helm, and `eksctl`
- AWS credentials with permission to create the Terraform resources and the
  IAM resources needed by the AWS Load Balancer Controller
- An AWS account and region that support the configured EKS version and EC2
  instance types

> **Cost warning:** EKS, EC2 nodes, NAT Gateways, Elastic IPs, ALBs, and data
> transfer can incur charges. Review Terraform plans and AWS pricing, and clean
> up resources when you finish.

### 1. Provision EKS with Terraform

The Terraform defaults are region `eu-west-3` and cluster name
`my-eks-cluster`. From the repository root:

```bash
cd infra
terraform init
terraform validate
terraform plan
terraform apply
```

Review the plan before approving it. When provisioning completes, configure
kubectl to use the EKS cluster and verify access:

```bash
aws eks update-kubeconfig --region eu-west-3 --name my-eks-cluster
kubectl config current-context
kubectl get nodes
```

If you changed the Terraform region or cluster name, use those values instead.
Before continuing, make sure the current kubectl context is the EKS context,
not a local kind context. The current default node group uses two `t3.small`
instances; the application has many workloads and may need additional or larger
nodes to fit all pods. Scaling nodes increases cost.

### 2. Configure IAM OIDC for the cluster

Run the following from a shell with AWS credentials and the EKS context
available. Set the values to match your cluster:

```bash
export cluster_name=my-eks-cluster
export region=eu-west-3
```

Get the cluster's OIDC issuer ID:

```bash
oidc_id=$(aws eks describe-cluster \
  --name "$cluster_name" \
  --region "$region" \
  --query 'cluster.identity.oidc.issuer' \
  --output text | cut -d '/' -f 5)
echo "$oidc_id"
```

Check whether an IAM OIDC provider already exists for that issuer:

```bash
aws iam list-open-id-connect-providers --output text | grep -F "$oidc_id"
```

If the command finds no matching provider, associate one:

```bash
eksctl utils associate-iam-oidc-provider \
  --cluster "$cluster_name" \
  --region "$region" \
  --approve
```

### 3. Create the controller IAM policy and service account

Download the IAM policy document that matches the AWS Load Balancer Controller
version you plan to install. This example uses the v2.11.0 policy document:

```bash
curl -o /tmp/aws-load-balancer-controller-iam-policy.json \
  https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json
```

Create the customer-managed IAM policy:

```bash
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file:///tmp/aws-load-balancer-controller-iam-policy.json
```

If the policy already exists, reuse its ARN rather than trying to create a
duplicate. Get the AWS account ID and form the policy ARN:

```bash
account_id=$(aws sts get-caller-identity --query Account --output text)
policy_arn="arn:aws:iam::${account_id}:policy/AWSLoadBalancerControllerIAMPolicy"
echo "$policy_arn"
```

Create the IAM role and Kubernetes service account using IRSA:

```bash
eksctl create iamserviceaccount \
  --cluster "$cluster_name" \
  --region "$region" \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn "$policy_arn" \
  --approve
```

### 4. Install the AWS Load Balancer Controller

Get the VPC ID from Terraform state from the repository root:

```bash
vpc_id=$(terraform -chdir=infra output -raw vpc_id)
echo "$vpc_id"
```

Use that VPC ID and the region/cluster values above when installing the
controller. Set `<chart-version>` to the Helm chart release that matches the
IAM policy document and controller release you chose:

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --version "<chart-version>" \
  --namespace kube-system \
  --set clusterName="$cluster_name" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region="$region" \
  --set vpcId="$vpc_id"
```

Verify the controller deployment becomes available:

```bash
kubectl rollout status deployment/aws-load-balancer-controller -n kube-system
kubectl get deployment -n kube-system aws-load-balancer-controller
```

If the controller reports access-denied errors or the Ingress never receives
an ALB address, check its logs and confirm the IAM policy matches the installed
controller version. The policy must include every permission required by that
version, including `elasticloadbalancing:DescribeListenerAttributes` where
required.

### 5. Deploy the app and expose it through the ALB

The AWS Load Balancer Controller discovers public subnets by their tags. The
current Terraform configuration does not add these tags, so tag the public
subnets in the AWS Console (or update your Terraform configuration) before
creating the Ingress:

- `kubernetes.io/role/elb` = `1`
- `kubernetes.io/cluster/my-eks-cluster` = `shared`

Use your actual cluster name in the cluster tag. Apply the `elb` role tag to
the public subnets that route to the Internet Gateway.

From the repository root, confirm the active context is EKS, then deploy all
manifests, including the frontend proxy Service and Ingress:

```bash
kubectl config current-context
kubectl apply -f k8s/microservices/
kubectl get pods -w
```

The frontend proxy Service uses `NodePort`. The Ingress is configured for ALB
`ip` targets, which route directly to pod IPs. Check the Ingress while the
controller provisions the load balancer:

```bash
kubectl get ingress frontend-proxy --watch
```

The current Ingress host is `ecommerce-ops.com`. Replace it in
`k8s/microservices/frontendproxy-Ingress.yaml` with a domain you control. To
use the ALB DNS name directly for testing, remove the `host` field from the
Ingress rule before applying it. Once the Ingress has an address, configure
your domain's DNS to point to the ALB. HTTPS is not configured in this demo;
it requires an ACM certificate and corresponding Ingress TLS/certificate
configuration.

### Clean up the AWS deployment

Delete the application resources first so the controller can remove the ALB:

```bash
kubectl delete -f k8s/microservices/
kubectl get ingress -A
```

Wait for the Ingress and associated ALB to be deleted before uninstalling the
controller:

```bash
helm uninstall aws-load-balancer-controller -n kube-system
eksctl delete iamserviceaccount \
  --cluster "$cluster_name" \
  --region "$region" \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --wait
```

Delete the IAM policy only if no other roles or users depend on it. Check for
remaining attachments first:

```bash
aws iam list-entities-for-policy --policy-arn "$policy_arn"
```

If no entities are attached and the policy is no longer used, delete it:

```bash
aws iam delete-policy --policy-arn "$policy_arn"
```

The OIDC provider is separate from Terraform-managed EKS resources; it is safe
to leave it in IAM if you are unsure whether anything else uses it. Finally,
destroy the Terraform-managed infrastructure:

```bash
cd infra
terraform plan -destroy
terraform destroy
```

Review the destroy plan before confirming, then verify in AWS that the ALB,
NAT Gateways, and other resources have been removed.

## Project scope

This is a learning and portfolio demo, not a production deployment. A
production setup would additionally need appropriate secrets management,
TLS and domain automation, resource and health policies, a configured
telemetry backend, and thoroughly reviewed IAM and network controls. The
application manifests reference an OpenTelemetry Collector that is not
included here, so telemetry-export errors are expected until one is deployed.
