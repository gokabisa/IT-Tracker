# kabisa-fleet Helm chart

Deploys Fleet (osquery) to the Kabisa Kubernetes cluster (arm64 Kapsule). Image
is built from this fork via `.github/workflows/kabisa-build-fleet.yml` and
pushed to `ghcr.io/gokabisa/fleet`.

## Prerequisites

- `kubectl` pointed at the target cluster (`admin@k8s-infrastructure`)
- `helm` 3.x
- Namespace `kabisa-app` exists
- Secrets in `kabisa-app`:
  - `fleet-mysql` — key `mysql-password` (external MySQL password)
  - `fleet-server-key` — key `FLEET_SERVER_PRIVATE_KEY` (32 chars exactly)
  - `ghcr-secret` — GHCR pull secret (`kubectl create secret docker-registry`)
- DNS `it.k8s.gokabisa.com` resolves to the Traefik LoadBalancer
- Fleet image `ghcr.io/gokabisa/fleet:<tag>` published (run the build workflow)

## One-time secret creation

```bash
kubectl create secret docker-registry ghcr-secret \
  -n kabisa-app \
  --docker-server=ghcr.io \
  --docker-username=<gh-user> \
  --docker-password=<gh-pat-with-read:packages>
```

## Deploy

```bash
cd deploy/kabisa-fleet
helm dependency build
helm upgrade --install fleet . \
  -n kabisa-app \
  --set image.tag=v4.84.3 \
  --timeout 10m
```

The chart runs `fleet prepare db` as a Helm pre-install/pre-upgrade Job. The
main Deployment only starts after migrations succeed.

## Verify

```bash
kubectl get pods -n kabisa-app -l app.kubernetes.io/name=kabisa-fleet
kubectl logs -n kabisa-app -l app.kubernetes.io/name=kabisa-fleet --tail=100
curl -sI https://it.k8s.gokabisa.com/healthz
```

The Traefik IngressRoute (`it.k8s.gokabisa.com`) lives in the
`gokabisa/ingress-traefik` repo and is applied separately.

## Upgrade Fleet version

1. Bump `appVersion` in `Chart.yaml`
2. Run the build workflow with the new tag
3. `helm upgrade --install fleet . -n kabisa-app --set image.tag=<new-tag>`
