# Argo CD project and label conventions

Argo CD AppProjects are authorization boundaries. Each project must explicitly allow its Git sources, destination namespaces and required cluster-scoped resources.

## Naming

- Applications: `<application>-<environment>`
- AppProjects: `<application-or-platform-domain>`
- Environments: `nonprod` and `prod`

Examples:

- `fairshare-nonprod`
- `fairshare-prod`
- `fairshare` AppProject

## Application labels

Every Argo CD Application uses:

| Label | Purpose |
|---|---|
| `app.kubernetes.io/name` | Application name |
| `app.kubernetes.io/instance` | Unique environment instance |
| `app.kubernetes.io/part-of` | Parent product |
| `platform.takunda.cloud/environment` | `nonprod` or `prod` |
| `platform.takunda.cloud/category` | `workload` or `platform` |

Example filters:

```bash
kubectl get applications -n argocd \
  -l platform.takunda.cloud/environment=prod

kubectl get applications -n argocd \
  -l platform.takunda.cloud/category=workload
```

## Project grouping

Application workloads use projects restricted to their required repositories and namespaces.

Shared services such as Argo CD, cert-manager, ingress and monitoring should use a separate `platform` AppProject. That project should list only the namespaces and cluster-scoped resource kinds each service requires.

New Applications should not remain in the permissive `default` project after their required permissions are understood.

## Registration order

Apply AppProjects before Applications:

```bash
kubectl apply -k argocd/projects
kubectl apply -k argocd/fairshare
kubectl apply -k argocd/portfolio
```
