# FruitKu

FruitKu is deployed to nonproduction as a single Next.js workload.

## Prerequisites

- Point `fruitku-nonprod.takunda.cloud` at the platform using the same DNS pattern as the other applications.
- Ensure `ghcr.io/taku10/fruitku` is publicly pullable, or configure an image pull secret in `nonprod`.
- Add `fruitku-nonprod.takunda.cloud` to Firebase Authentication's authorized domains.\n- Create a Stripe **test-mode** server key before Argo CD synchronizes the application:

```bash
read -rsp "Stripe secret key: " FRUITKU_STRIPE_SECRET
echo

kubectl create secret generic fruitku-runtime \
  --namespace nonprod \
  --from-literal=STRIPE_SECRET_KEY="$FRUITKU_STRIPE_SECRET" \
  --dry-run=client \
  -o yaml | kubectl apply -f -

unset FRUITKU_STRIPE_SECRET
```

The public Firebase, Stripe and EmailJS configuration is compiled into the image by the FruitKu GitHub Actions workflow. Do not store the Stripe secret key in Git or in a `NEXT_PUBLIC_` variable.\n\nFruitKu currently accepts product names and prices from the browser when creating a Stripe Checkout session. Use test mode only in nonproduction. Before production, change the API to resolve trusted product IDs and prices on the server.

## Verification

```bash
kubectl get application fruitku-nonprod -n argocd
kubectl get deployment,pod,service,ingress -n nonprod -l app.kubernetes.io/name=fruitku
curl --fail https://fruitku-nonprod.takunda.cloud/api/health
```
