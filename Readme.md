
# k3s Platform

A self-hosted Kubernetes platform for deploying and managing my personal projects.

The cluster runs on an OVH VPS using k3s. Argo CD handles GitOps deployments, Traefik handles ingress, and Prometheus/Grafana are used for monitoring.

## Stack

- k3s
- Argo CD
- Traefik
- cert-manager
- Prometheus
- Grafana
- Headlamp
- Kustomize
- GitHub Actions
- GHCR

## Environments

Applications are separated using Kubernetes namespaces.

```text
k3s
├── argocd
├── monitoring
├── nonprod
└── prod
````

Development is done with Docker Compose before changes are deployed to nonprod.

Nonprod is used for testing before changes are promoted to production.

## Deployment Flow

```
+------------------+
| Application Code |
+------------------+
         |
         v
+------------------+
|      GitHub      |
+------------------+
         |
         v
+------------------+
|  GitHub Actions  |
+------------------+
         |
         v
+------------------+
| Build Docker Img |
+------------------+
         |
         v
+------------------+
|       GHCR       |
+------------------+
         |
         v
+------------------+
|  GitOps Config   |
+------------------+
         |
         v
+------------------+
|     Argo CD      |
+------------------+
         |
         v
+------------------+
|       k3s        |
+------------------+
```

## Applications

Applications running or planned for the platform:

* FairShare
* Personal Portfolio
* Fruiku
* StackCash

## Networking

```
+--------------------+
|      Internet      |
+--------------------+
          |
          v
+--------------------+
|        DNS         |
+--------------------+
          |
          v
+--------------------+
|      OVH VPS       |
+--------------------+
          |
          v
+--------------------+
|        UFW         |
+--------------------+
          |
          v
+--------------------+
|      Traefik       |
+--------------------+
          |
          v
+--------------------+
| Kubernetes Service |
+--------------------+
          |
          v
+--------------------+
|        Pod         |
+--------------------+
```

TLS certificates are managed with cert-manager.

## Current Work

* Create separate nonprod and prod deployments
* Replace `latest` image tags with Git SHA tags
* Add more applications to the cluster
* Add centralized logging
* Improve monitoring and alerting
* Add NetworkPolicies
* Improve secrets management
* Add backup and recovery procedures
* Introduce Helm for application deployments

## Goal

The goal of this project is to build a small platform for deploying and managing multiple applications while improving my experience with Kubernetes, GitOps, CI/CD, networking, monitoring, and platform engineering.



