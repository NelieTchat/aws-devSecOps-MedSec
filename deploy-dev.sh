#!/usr/bin/env bash
set -euo pipefail

# ----- Config (override via env if needed) -----
AWS_REGION="${AWS_REGION:-us-west-2}"
ECR_REPO="${ECR_REPO:-medsec-portal-dev}"
TF_DIR="${TF_DIR:-infra/terraform/envs/dev}"

# ----- Pre-flight checks -----
need() { command -v "$1" >/dev/null 2>&1 || { echo "❌ Missing $1"; exit 1; }; }
need aws; need jq; need terraform; need curl

echo "👉 Using region: ${AWS_REGION}"
echo "👉 Using ECR repo: ${ECR_REPO}"
echo "👉 Terraform dir: ${TF_DIR}"
echo

# ----- Find latest dev-* image tag in ECR -----
echo "🔎 Finding latest dev-* image tag in ECR..."
ECR_JSON="$(aws ecr describe-images \
  --region "$AWS_REGION" \
  --repository-name "$ECR_REPO" \
  --output json)"

IMAGE_TAG="$(echo "$ECR_JSON" \
  | jq -r '[.imageDetails[]
            | {pushedAt:.imagePushedAt, tags:(.imageTags // [])}]
           | sort_by(.pushedAt) | reverse
           | map(.tags[]) 
           | map(select(test("^dev-")))
           | .[0]')"

if [[ -z "${IMAGE_TAG:-}" || "${IMAGE_TAG}" == "null" ]]; then
  echo "❌ Could not find an image tag matching ^dev- in ECR repo ${ECR_REPO}"
  echo "   Make sure your CI pushed an image (branch dev)."
  exit 1
fi

echo "✅ Latest tag: ${IMAGE_TAG}"
echo

# ----- Terraform apply with that tag -----
cd "$TF_DIR"
echo "📦 terraform init (upgrade providers if needed)..."
terraform init -upgrade -input=false

echo "🚀 terraform apply (image_tag=${IMAGE_TAG})..."
terraform apply -auto-approve -input=false -var="image_tag=${IMAGE_TAG}"

# ----- Fetch outputs -----
ALB_DNS="$(terraform output -raw alb_dns)"
CLUSTER_ARN="$(terraform output -raw ecs_cluster_arn)"
SERVICE_NAME="$(terraform output -raw service_name)"

CLUSTER_NAME="${CLUSTER_ARN##*/}"

echo
echo "⏳ Waiting for ECS service to stabilize..."
aws ecs wait services-stable \
  --region "$AWS_REGION" \
  --cluster "$CLUSTER_NAME" \
  --services "$SERVICE_NAME"

echo "✅ Service stable."

# ----- Health check via ALB -----
echo
echo "🔍 Health check via ALB:"
echo "    http://${ALB_DNS}/health"
set +e
curl -fsS "http://${ALB_DNS}/health" || true
echo
echo "Done ✅"
