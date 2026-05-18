#!/usr/bin/env bash
# deploy.sh — Bootstrap FreshMart on OpenShift with Argo CD
#
# Usage:
#   ./deploy.sh              # apply Argo CD project/rbac/application
#   ./deploy.sh --direct     # apply workload manifests directly (without Argo CD)
#   ./deploy.sh --teardown   # delete app + project + rbac + direct manifests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$SCRIPT_DIR"
APP_NAMESPACE="freshmart"
ARGO_NAMESPACE="openshift-gitops"

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: '$cmd' not found in PATH." >&2
    exit 1
  fi
}

echo ""
echo "==> Checking prerequisites..."
require_cmd kubectl

context="$(kubectl config current-context)"
echo "  Kubernetes context: $context"

# ── Teardown ──────────────────────────────────────────────────────
if [[ "${1:-}" == "--teardown" ]]; then
  echo ""
  echo "==> Removing Argo CD resources..."
  kubectl delete -f "$K8S_DIR/argocd-application.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/argocd-rbac.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/argocd-project.yaml" --ignore-not-found

  echo ""
  echo "==> Removing workload manifests (safe if they were Argo-managed)..."
  kubectl delete -f "$K8S_DIR/instana-agent.customresource.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/frontend-deployment.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/backend-deployment.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/prometheus-deployment.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/grafana-deployment.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/postgres-initdb.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/postgres-cluster.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/buildconfig-backend.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/buildconfig-frontend.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/imagestream-backend.yaml" --ignore-not-found
  kubectl delete -f "$K8S_DIR/imagestream-frontend.yaml" --ignore-not-found

  echo ""
  echo "Teardown completed."
  exit 0
fi

# ── Direct apply mode (without Argo CD) ──────────────────────────
if [[ "${1:-}" == "--direct" ]]; then
  echo ""
  echo "==> Creating namespace '$APP_NAMESPACE' (if needed)..."
  kubectl create namespace "$APP_NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

  echo ""
  echo "==> Applying OpenShift workload manifests directly..."
  kubectl apply -f "$K8S_DIR/imagestream-backend.yaml"
  kubectl apply -f "$K8S_DIR/imagestream-frontend.yaml"
  kubectl apply -f "$K8S_DIR/buildconfig-backend.yaml"
  kubectl apply -f "$K8S_DIR/buildconfig-frontend.yaml"
  kubectl apply -f "$K8S_DIR/postgres-cluster.yaml"
  kubectl apply -f "$K8S_DIR/postgres-initdb.yaml"
  kubectl apply -f "$K8S_DIR/backend-deployment.yaml"
  kubectl apply -f "$K8S_DIR/frontend-deployment.yaml"
  kubectl apply -f "$K8S_DIR/prometheus-deployment.yaml"
  kubectl apply -f "$K8S_DIR/grafana-deployment.yaml"

  echo ""
  echo "NOTE: Instana agent CR is not auto-applied in --direct mode."
  echo "Create namespace/secret first, then apply it manually:"
  echo "  kubectl create namespace instana-agent"
  echo "  kubectl -n instana-agent create secret generic instana-agent-keys --from-literal=key=<KEY> --from-literal=downloadKey=<DOWNLOAD_KEY>"
  echo "  kubectl apply -f $K8S_DIR/instana-agent.customresource.yaml"
  exit 0
fi

# ── Argo CD bootstrap mode (default) ─────────────────────────────
echo ""
echo "==> Checking Argo CD namespace '$ARGO_NAMESPACE'..."
kubectl get namespace "$ARGO_NAMESPACE" >/dev/null

echo ""
echo "==> Applying Argo CD project and permissions..."
kubectl apply -f "$K8S_DIR/argocd-project.yaml"
kubectl apply -f "$K8S_DIR/argocd-rbac.yaml"

echo ""
echo "==> Applying Argo CD application..."
kubectl apply -f "$K8S_DIR/argocd-application.yaml"

echo ""
echo "Argo CD bootstrap completed."
echo "Next steps for Instana operator-managed agent:"
echo "  1) kubectl create namespace instana-agent"
echo "  2) kubectl -n instana-agent create secret generic instana-agent-keys --from-literal=key=<KEY> --from-literal=downloadKey=<DOWNLOAD_KEY>"
echo "  3) Ensure your Argo app syncs $K8S_DIR/instana-agent.customresource.yaml (or apply it manually)"