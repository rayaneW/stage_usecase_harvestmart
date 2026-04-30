#!/usr/bin/env bash
# deploy.sh — Build Docker images and deploy FreshMart to Minikube
# Requires: Minikube and kubectl
#
# Usage:    ./deploy.sh
# Teardown: ./deploy.sh --teardown

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../bakery-backend/bakery-backend"
FRONTEND_DIR="$SCRIPT_DIR/../HarvestMart"
K8S_DIR="$SCRIPT_DIR"
NAMESPACE="freshmart"

# ── Teardown ──────────────────────────────────────────────────────
if [[ "${1:-}" == "--teardown" ]]; then
  echo ""
  echo "==> Removing all K8s resources..."
  kubectl delete -f "$K8S_DIR/grafana-deployment.yaml"    --ignore-not-found
  kubectl delete -f "$K8S_DIR/prometheus-deployment.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/frontend-deployment.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/backend-deployment.yaml"  --ignore-not-found
  kubectl delete -f "$K8S_DIR/postgres-deployment.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/postgres-secret.yaml"     --ignore-not-found
  kubectl delete -f "$K8S_DIR/namespace.yaml"           --ignore-not-found
  echo ""
  echo "All resources removed."
  exit 0
fi

# ── Check prerequisites ───────────────────────────────────────────
echo ""
echo "==> Checking prerequisites..."

if ! command -v kubectl &>/dev/null; then
  echo "ERROR: kubectl not found." >&2
  exit 1
fi

if ! command -v minikube &>/dev/null; then
  echo "ERROR: minikube not found." >&2
  exit 1
fi

if ! command -v docker &>/dev/null; then
  echo "ERROR: docker not found." >&2
  exit 1
fi

context=$(kubectl config current-context)
echo "  Kubernetes context: $context"

if [[ "$context" != "minikube" ]]; then
  echo "ERROR: Current context is '$context'. Please switch to minikube: kubectl config use-context minikube" >&2
  exit 1
fi

# ── Build Docker images ───────────────────────────────────────────
echo ""
echo "==> Building backend Docker image (bakery-backend:latest)..."
docker build -t bakery-backend:latest "$BACKEND_DIR"

echo ""
echo "==> Building frontend Docker image (harvestmart-frontend:latest)..."
docker build -t harvestmart-frontend:latest "$FRONTEND_DIR"

# ── Apply K8s manifests ───────────────────────────────────────────
echo ""
echo "==> Applying Kubernetes manifests..."
kubectl apply -f "$K8S_DIR/namespace.yaml"
kubectl apply -f "$K8S_DIR/postgres-secret.yaml"
kubectl apply -f "$K8S_DIR/postgres-deployment.yaml"
kubectl apply -f "$K8S_DIR/backend-deployment.yaml"
kubectl apply -f "$K8S_DIR/prometheus-deployment.yaml"
kubectl apply -f "$K8S_DIR/grafana-deployment.yaml"
kubectl apply -f "$K8S_DIR/frontend-deployment.yaml"

# ── Wait for deployments ──────────────────────────────────────────
echo ""
echo "==> Waiting for pods to be ready (this may take ~60s)..."
kubectl rollout status deployment/postgres -n "$NAMESPACE"             --timeout=120s
kubectl rollout status deployment/bakery-backend -n "$NAMESPACE"       --timeout=120s
kubectl rollout status deployment/prometheus -n "$NAMESPACE"           --timeout=120s
kubectl rollout status deployment/grafana -n "$NAMESPACE"              --timeout=120s
kubectl rollout status deployment/harvestmart-frontend -n "$NAMESPACE" --timeout=60s

# ── Done ──────────────────────────────────────────────────────────
echo ""
echo "========================================"
echo "  FreshMart is running!"
echo "  Access services via NodePort/port-forward"
echo "  Prometheus: http://localhost:30090"
echo "  Grafana: http://localhost:30300 (admin/admin)"
echo "  Freshmart frontend (port-forward): kubectl port-forward -n $NAMESPACE svc/harvestmart-frontend-service 30000:80"
echo "  Freshmart backend  (port-forward): kubectl port-forward -n $NAMESPACE svc/bakery-backend-service 8081:8080"
echo "  ArgoCD UI          (port-forward): kubectl port-forward -n argocd svc/argocd-server 8080:443"
echo "  ArgoCD admin password command: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | %{ [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) }"
echo "  Namespace: $NAMESPACE"
echo "========================================"
echo ""
kubectl get pods -n "$NAMESPACE"