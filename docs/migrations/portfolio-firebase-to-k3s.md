# Portfolio migration from Firebase Hosting to K3s

The portfolio was moved from Firebase Hosting to the self-hosted K3s platform. Firebase Authentication and Firestore remain in use; only website hosting moved to Kubernetes.

## Deployment flow

```text
Application repository
→ GitHub Actions
→ GHCR image tagged with a commit SHA
→ Kustomize overlay
→ Argo CD
→ K3s
→ Traefik
```

## Migration

1. Build and publish the portfolio container to GHCR.
2. Update the nonproduction Kustomize overlay with the immutable image tag.
3. Register the nonproduction Argo CD Application and verify the workload.
4. Promote the tested image tag to the production overlay.
5. Register the production Argo CD Application.
6. Update the public DNS record to direct production traffic to the K3s ingress.
7. Verify the production site before disabling Firebase Hosting.

## Verification

```bash
kubectl get applications -n argocd
kubectl get pods,service,ingress -n nonprod
kubectl get pods,service,ingress -n prod
kubectl get certificates -A
curl -I https://takunda.cloud
curl https://takunda.cloud/healthz
```

A successful migration has healthy Argo CD Applications, running pods, ready certificates, an HTTP success response and an `ok` health response.

## Rollback

If production validation fails, restore the previous DNS destination and investigate the Kubernetes deployment before attempting the cutover again.

Do not store credentials, access tokens, kubeconfig files, registry secrets or infrastructure addresses in this document.
