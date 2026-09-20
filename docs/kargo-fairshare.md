# FairShare delivery with Kargo

Kargo promotes matching FairShare client and server images through nonproduction and production. Argo CD remains responsible for deploying the generated manifests to K3s.

## Release flow

1. GitHub Actions publishes the client and server images with the same seven-character commit tag.
2. The FairShare Warehouse creates Freight only after both images with that tag exist.
3. Kargo automatically renders and pushes `stage/nonprod`.
4. Argo CD deploys the branch and Kargo waits for the Application to become healthy.
5. After a five-minute soak, the Freight becomes available for a manual production promotion.
6. A production promotion renders and pushes `stage/prod`; Argo CD then deploys it.

Kargo never writes generated manifests to `main`.

## One-time setup

Kargo's API credentials must exist before Argo CD installs the Helm release. Generate them locally and store them only in Kubernetes:

```bash
sudo apt-get install -y apache2-utils

kubectl create namespace kargo --dry-run=client -o yaml | kubectl apply -f -

read -rsp "Kargo admin password: " KARGO_PASSWORD
echo
KARGO_PASSWORD_HASH="$(htpasswd -bnBC 10 '' "$KARGO_PASSWORD" | tr -d ':\n')"
KARGO_SIGNING_KEY="$(openssl rand -base64 48 | tr -d '=+/' | head -c 32)"

kubectl create secret generic kargo-api \
  --namespace kargo \
  --from-literal=ADMIN_ACCOUNT_PASSWORD_HASH="$KARGO_PASSWORD_HASH" \
  --from-literal=ADMIN_ACCOUNT_TOKEN_SIGNING_KEY="$KARGO_SIGNING_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

unset KARGO_PASSWORD KARGO_PASSWORD_HASH KARGO_SIGNING_KEY
```

After the `fairshare` Kargo Project has created its namespace, add a fine-grained GitHub token limited to `Taku10/k3s-platform` with **Contents: Read and write**:

```bash
read -rsp "GitHub token: " KARGO_GITHUB_TOKEN
echo

kubectl create secret generic fairshare-git \
  --namespace fairshare \
  --from-literal=repoURL=https://github.com/Taku10/k3s-platform.git \
  --from-literal=username=Taku10 \
  --from-literal=password="$KARGO_GITHUB_TOKEN" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl label secret fairshare-git \
  --namespace fairshare \
  kargo.akuity.io/cred-type=git \
  --overwrite

unset KARGO_GITHUB_TOKEN
```

If the FairShare GHCR packages are private, add a separate read-only package credential. Do not reuse the Git write token:

```bash
read -rsp "GHCR read token: " KARGO_GHCR_TOKEN
echo

kubectl create secret generic fairshare-ghcr \
  --namespace fairshare \
  --from-literal=repoURL='^ghcr\.io/taku10/fairshare-(client|server)$' \
  --from-literal=repoURLIsRegex=true \
  --from-literal=username=Taku10 \
  --from-literal=password="$KARGO_GHCR_TOKEN" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl label secret fairshare-ghcr \
  --namespace fairshare \
  kargo.akuity.io/cred-type=image \
  --overwrite

unset KARGO_GHCR_TOKEN
```

This credential lets Kargo discover private images. The `nonprod` and `prod` namespaces still need their own Kubernetes image-pull secret if the packages are private.

## Verify the installation

```bash
kubectl get applications -n argocd kargo fairshare-delivery
kubectl get pods -n kargo
kubectl get warehouses,stages -n fairshare
```

The FairShare Argo CD Applications will report a missing `stage/nonprod` or `stage/prod` branch until each environment receives its first promotion. That is expected.

For local-only dashboard access:

```bash
kubectl port-forward -n kargo service/kargo-api 8080:443
```

Open `https://localhost:8080`. Production promotion stays manual; select Freight that has passed nonproduction and click **Promote** on the production stage.

## Rollback

Promote an older verified Freight to the affected stage. Kargo writes the older image tags to that stage branch, and Argo CD reconciles the cluster back to that release.
