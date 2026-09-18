# K3s Platform

A self-hosted Kubernetes platform for deploying and managing personal projects on an OVH VPS.

K3s provides the Kubernetes cluster, Argo CD manages GitOps deployments, Traefik handles ingress, and cert-manager provisions TLS certificates.

## Stack

- K3s
- Argo CD
- Traefik
- cert-manager
- Prometheus
- Grafana
- Headlamp
- Kustomize
- GitHub Actions
- GitHub Container Registry

## Repository responsibility

This repository stores the desired state of applications and platform components running inside Kubernetes.

Linux host configuration, K3s installation and the initial Argo CD bootstrap are maintained separately in [Taku10/ovh-infra](https://github.com/Taku10/ovh-infra).

## Environments

Applications are separated with Kubernetes namespaces:

```text
k3s
├── argocd
├── monitoring
├── nonprod
└── prod
```

Nonproduction is used for validation before changes are promoted to production.

## Applications

### FairShare

FairShare uses a shared Kustomize base with production and nonproduction overlays:

```text
apps/fairshare/
├── base/
└── overlays/
    ├── nonprod/
    └── prod/
```

### Personal portfolio

The portfolio is deployed as a static Next.js export served by an unprivileged Nginx container:

```text
apps/portfolio/
├── base/
└── overlays/
    ├── nonprod/
    └── prod/
```

Endpoints:

- Production: `https://takunda.cloud`
- Nonproduction: `https://portfolio-nonprod.takunda.cloud`

Container images are published to GHCR using immutable full Git commit SHA tags.

## Deployment flow

```text
Application source
       |
       v
GitHub Actions
       |
       v
GHCR image tagged with commit SHA
       |
       v
Kustomize environment overlay
       |
       v
Argo CD
       |
       v
K3s
```

## Register Argo CD applications

Until a root bootstrap Application is added, register application definitions manually:

```bash
kubectl apply -k argocd/fairshare
kubectl apply -k argocd/portfolio
```

Argo CD then synchronizes the corresponding Kustomize overlays.

## Networking

Public traffic follows this path:

```text
Internet
   |
   v
DNS
   |
   v
OVH VPS
   |
   v
Traefik
   |
   v
Kubernetes Service
   |
   v
Application Pod
```

TLS certificates are managed by cert-manager.

## Current work

- Move Headlamp and monitoring installation into GitOps
- Add a root Argo CD bootstrap Application
- Add centralized logging
- Improve monitoring and alerting
- Add NetworkPolicies
- Improve secrets management
- Add backup and recovery procedures

## Goal

The goal is to build a small, production-minded platform for deploying multiple applications while developing practical experience with Kubernetes, GitOps, CI/CD, networking, monitoring and platform engineering.
