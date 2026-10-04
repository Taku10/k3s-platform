# Portfolio delivery with Kargo

GitHub Actions in `takunda-profile` publishes `ghcr.io/taku10/takunda-profile` with an immutable 40-character commit tag. The portfolio Warehouse discovers these builds. Nonproduction promotes automatically; production requires manual promotion after the Freight has been healthy in nonproduction for five minutes.

Kargo renders `apps/portfolio/overlays/<stage>` from `main`, changes its image to the selected Freight, and pushes generated manifests to `stage/portfolio/nonprod` or `stage/portfolio/prod`. Argo CD deploys that commit. These branches are separate from FairShare's branches because promotions clear the destination working tree. Kargo does not change `main` or the checked-in overlay tags.

## Activate

Before merging the Argo CD application changes, bootstrap both stage branches from their current portfolio overlays. Otherwise Argo CD will report a missing branch until the first promotion. Use a separate temporary clone of `Taku10/k3s-platform`; render each current overlay using `kubectl kustomize`, create its orphan stage branch, commit the rendered YAML at the branch root, and push it. Do not clear the main working checkout. Bootstrap production with its currently deployed image, not the newest Warehouse image.

The existing Kargo controller and API credentials are reused. Once the `portfolio` Kargo Project creates its namespace, create a Git credential in that namespace with access to `Taku10/k3s-platform`. Follow the Git credential setup in [kargo-fairshare.md](kargo-fairshare.md), replacing the namespace with `portfolio` and secret name with `portfolio-git`. The token needs Contents read/write and permission to push the two portfolio stage branches. Do not commit credentials.

If the GHCR package is private, follow the image credential setup in that guide with namespace `portfolio`, secret name `portfolio-ghcr`, and exact `repoURL=ghcr.io/taku10/takunda-profile` (omit the regex flag). Cluster image-pull credentials still belong in the workload namespaces.

Commit and push the manifests through the normal GitOps process. The bootstrap Argo CD Application discovers `portfolio-delivery`, which applies `kargo/portfolio`. With the Git credential present, Kargo can automatically promote into nonproduction.

## Verify and promote

```bash
kubectl get applications -n argocd portfolio-delivery portfolio-nonprod portfolio-prod
kubectl get warehouses,freights,stages,promotions -n portfolio
```

Verify the nonproduction site and owner publishing before selecting that Freight and manually promoting to `prod` in Kargo. The five-minute soak is a health gate, not an application test. Image promotion changes application code; published portfolio content in Firestore is shared by environments configured with the same Firebase project.

For rollback, manually promote an older verified Freight to the affected stage. Firebase document changes are not rolled back by image promotion.
