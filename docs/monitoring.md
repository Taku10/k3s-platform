# Application monitoring

The first monitoring dashboard provides a plain-language production overview for FairShare, the portfolio and FruitKu.

## What it shows

- Whether every requested production replica is available
- Requests served during the last 24 hours
- Percentage of requests without HTTP 5xx errors
- 95th-percentile response time
- Server errors during the last 24 hours
- Container restarts during the last 24 hours

Request totals represent HTTP traffic, not unique visitors.

## Data sources

The dashboard uses metrics already collected by the platform:

- Traefik request and response-time metrics
- kube-state-metrics deployment and pod metrics
- Prometheus as the Grafana data source

Business events such as household creation, chore completion, checkout completion and resume downloads are intentionally excluded until the applications expose trusted metrics.

## Provisioning

The dashboard is stored in Git as a ConfigMap with this label:

```yaml
grafana_dashboard: "1"
```

The Grafana dashboard sidecar discovers the ConfigMap in the `monitoring` namespace and loads the dashboard automatically.

Argo CD manages the ConfigMap through the `monitoring-config` Application.

## After merging

The bootstrap Application does not manage its own definition. Reapply it once after adding the monitoring child Application:

```bash
git switch main
git pull --ff-only origin main

kubectl apply -f argocd/bootstrap/root-application.yaml
```

Verify the resources:

```bash
kubectl get application monitoring-config -n argocd
kubectl get configmap grafana-dashboard-application-overview -n monitoring
```

In Grafana, open **Dashboards** and select **Application Overview**.

## Troubleshooting

If the dashboard is missing, confirm that the Grafana sidecar watches the `monitoring` namespace and selects ConfigMaps labeled `grafana_dashboard=1`:

```bash
kubectl get configmap -n monitoring -l grafana_dashboard=1
kubectl get pods -n monitoring
```

If panels display no data, verify that Prometheus contains these metrics:

```text
kube_deployment_status_replicas_available
kube_deployment_spec_replicas
kube_pod_container_status_restarts_total
traefik_service_requests_total
traefik_service_request_duration_seconds_bucket
```

Do not make Grafana anonymously accessible on the public internet. Use authenticated read-only access for nontechnical viewers.

## Next steps

Add business metrics one application at a time:

1. FairShare household, chore and expense event counts
2. FruitKu product-view and Stripe-webhook checkout counts
3. Portfolio project clicks, resume downloads and contact submissions

Metrics must contain aggregated counts only. Do not use emails, user IDs, household names, payment details or other sensitive values as Prometheus labels.
