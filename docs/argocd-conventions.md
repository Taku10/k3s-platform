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

## Root bootstrap

The `platform-bootstrap` Application is the only Argo CD Application applied manually:

```bash
kubectl apply -f argocd/bootstrap/root-application.yaml
```

It recursively discovers Kubernetes manifests under `argocd/`. It excludes its own seed manifest and every `kustomization.yaml`, because directory mode applies Kubernetes resources directly rather than building Kustomize packages.

Keep AppProject and Application definitions under `argocd/`. An AppProject managed by the root Application must use sync wave `-1` so it is created before the Applications assigned to it:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
```

After the initial apply, commit Git changes and allow `platform-bootstrap` to synchronize them. Do not manually apply its child Application manifests.
