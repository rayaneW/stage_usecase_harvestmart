# deploy.ps1 — Build Docker images and deploy FreshMart to local Kubernetes
# Requires: Docker Desktop with Kubernetes enabled
#
# Usage:  .\deploy.ps1
# Teardown: .\deploy.ps1 -Teardown

param(
    [switch]$Teardown
)

$ErrorActionPreference = "Stop"

$BackendDir  = "$PSScriptRoot\..\bakery-backend\bakery-backend"
$FrontendDir = "$PSScriptRoot\..\HarvestMart"
$K8sDir      = $PSScriptRoot

function Write-Step($msg) {
    Write-Host "`n==> $msg" -ForegroundColor Cyan
}

# ── Teardown ──────────────────────────────────────────────────────
if ($Teardown) {
    Write-Step "Removing all K8s resources..."
    kubectl delete -f "$K8sDir\frontend-deployment.yaml" --ignore-not-found
    kubectl delete -f "$K8sDir\backend-deployment.yaml"  --ignore-not-found
    kubectl delete -f "$K8sDir\postgres-deployment.yaml" --ignore-not-found
    kubectl delete -f "$K8sDir\postgres-secret.yaml"     --ignore-not-found
    Write-Host "`nAll resources removed." -ForegroundColor Green
    exit 0
}

# ── Check prerequisites ───────────────────────────────────────────
Write-Step "Checking prerequisites..."

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Error "kubectl not found. Enable Kubernetes in Docker Desktop."
}
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "docker not found. Install Docker Desktop."
}

$context = kubectl config current-context
Write-Host "  Kubernetes context: $context" -ForegroundColor Yellow

# ── Build Docker images ───────────────────────────────────────────
Write-Step "Building backend Docker image (bakery-backend:latest)..."
Push-Location $BackendDir
docker build -t bakery-backend:latest .
Pop-Location

Write-Step "Building frontend Docker image (harvestmart-frontend:latest)..."
Push-Location $FrontendDir
docker build -t harvestmart-frontend:latest .
Pop-Location

# ── Apply K8s manifests ───────────────────────────────────────────
Write-Step "Applying Kubernetes manifests..."

kubectl apply -f "$K8sDir\postgres-secret.yaml"
kubectl apply -f "$K8sDir\postgres-deployment.yaml"
kubectl apply -f "$K8sDir\backend-deployment.yaml"
kubectl apply -f "$K8sDir\frontend-deployment.yaml"

# ── Wait for deployments ──────────────────────────────────────────
Write-Step "Waiting for pods to be ready (this may take ~60s)..."

kubectl rollout status deployment/postgres          --timeout=120s
kubectl rollout status deployment/bakery-backend    --timeout=120s
kubectl rollout status deployment/harvestmart-frontend --timeout=60s

# ── Done ──────────────────────────────────────────────────────────
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  FreshMart is running!" -ForegroundColor Green
Write-Host "  Open: http://localhost:30000" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

kubectl get pods
