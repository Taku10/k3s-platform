# FruitKu

FruitKu is deployed to the `prod` namespace as a single Next.js workload. A separate nonproduction environment can be added later if the project needs it.

## Prerequisites

- Point `fruitku.takunda.cloud` at the platform using the same DNS pattern as the other applications.
- Ensure `ghcr.io/taku10/fruitku` is publicly pullable, or configure an image pull secret in `prod`.
- Add `fruitku.takunda.cloud` to Firebase Authentication's authorized domains.
- Create the runtime Secret before Argo CD synchronizes the application.

For now, use a Stripe **test-mode** secret key:

```bash
read -rsp "Stripe test secret key: " FRUITKU_STRIPE_SECRET
echo

kubectl create secret generic fruitku-runtime \
  --namespace prod \
  --from-literal=STRIPE_SECRET_KEY="$FRUITKU_STRIPE_SECRET" \
  --dry-run=client \
  -o yaml | kubectl apply -f -

unset FRUITKU_STRIPE_SECRET
```

The public Firebase, Stripe and EmailJS configuration is compiled into the image by the FruitKu GitHub Actions workflow. Never store the Stripe secret key in Git or in a `NEXT_PUBLIC_` variable.

## Payment safety

The current checkout API accepts product names and prices from the browser. Keep Stripe in test mode until the API uses trusted product IDs and resolves prices on the server. The production namespace and hostname do not make live payments safe by themselves.

## Verification

```bash
kubectl get application fruitku-prod -n argocd
kubectl get deployment,pod,service,ingress -n prod -l app.kubernetes.io/name=fruitku
curl --fail https://fruitku.takunda.cloud/api/health
```
