# k3s-platform

This repository contains Kubernetes manifests for a k3s platform environment.

It includes:

- Application manifests for the Fairshare app (`apps/fairshare`)
- An Argo CD `Application` manifest for deploying Fairshare (`argocd/fairshare.yaml`)
- Ingress resources for public endpoints (`ingress/`)
- Traefik and cert-manager related manifests (`traefik/`)
- Traefik monitoring configuration for Grafana/Prometheus (`grafana/traefik-monitoring.yaml`)

## Repository layout

- `/apps/fairshare` — Fairshare namespace, deployments, and services
- `/argocd` — Argo CD application definitions
- `/ingress` — Ingress resources and certificate issuer configuration
- `/traefik` — Traefik-related ingress/certificate manifests
- `/grafana` — Monitoring configuration for Traefik metrics

## What this repo is for

Use this repository as the source of truth for the Kubernetes platform manifests that power the Fairshare environment on k3s.
