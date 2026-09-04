#!/usr/bin/env bash
# cd /home/ian/Projects/GCP/GCP/IAN
# source /home/ian/Projects/GCP/ENVS_IAN.sh 
# ./0-bootstrap.sh /home/ian/Projects/GCP/GCP/0-bootstrap ${TFSTATE_BUCKET_NAME}

set -euo pipefail

BOOTSTRAP_DIR="${1:-0-bootstrap}"
GCS_BACKEND_BUCKET="${2:-}"

if [[ -z "${GCS_BACKEND_BUCKET}" ]]; then
  echo "Usage:"
  echo "  $0 <bootstrap-directory> <gcs-backend-bucket>"
  echo
  echo "Example:"
  echo "  $0 ./0-bootstrap my-terraform-state-bucket"
  exit 1
fi

if [[ ! -d "${BOOTSTRAP_DIR}" ]]; then
  echo "ERROR: Directory not found: ${BOOTSTRAP_DIR}"
  exit 1
fi

cd "${BOOTSTRAP_DIR}"

echo "=================================================="
echo "Simplifying 0-bootstrap"
echo "Target CI/CD: GitHub Actions"
echo "Target backend: Google Cloud Storage"
echo "=================================================="

#
# Safety backup
#
BACKUP_DIR="../0-bootstrap-backup-$(date +%Y%m%d-%H%M%S)"

echo
echo "Creating backup:"
echo "  ${BACKUP_DIR}"

cp -a . "${BACKUP_DIR}"

#
# Activate GCS backend
#
echo
echo "Configuring GCS Terraform backend..."

if [[ -f "backend.tf.example" ]]; then
  mv "backend.tf.example" "backend.tf"
elif [[ ! -f "backend.tf" ]]; then
  echo "ERROR: Neither backend.tf.example nor backend.tf exists."
  exit 1
fi

sed -i \
  "s/UPDATE_ME/${GCS_BACKEND_BUCKET}/g" \
  backend.tf

#
# Activate root Terraform variables
#
echo
echo "Activating terraform.tfvars..."

if [[ -f "terraform.example.tfvars" ]]; then
  mv "terraform.example.tfvars" "terraform.tfvars"
elif [[ ! -f "terraform.tfvars" ]]; then
  echo "ERROR: terraform.example.tfvars not found."
  exit 1
fi

#
# Activate GitHub-compatible outputs
#
echo
echo "Activating outputs.tf..."

if [[ -f "outputs.tf.local" ]]; then
  mv "outputs.tf.local" "outputs.tf"
fi

#
# Confirm root GitHub configuration
#
echo
echo "Checking GitHub Terraform configuration..."

if [[ ! -f "github.tf" ]]; then
  echo "WARNING: github.tf is missing."
  echo "The supplied archive should contain an active root-level github.tf."
else
  echo "Found github.tf."
fi

#
# Remove alternative CI/CD documentation
#
echo
echo "Removing unused CI/CD documentation..."

rm -f \
  README-GitLab.md \
  README-Terraform-Cloud.md

#
# Remove alternative root configurations
#
echo
echo "Removing unused CI/CD configuration files..."

rm -f \
  backend.tf.cloud.example \
  backend.tf.local \
  cb.tf.example \
  gitlab.tf.example \
  jenkins.tf.example \
  terraform-local.tf.example \
  terraform_cloud.tf.example

#
# Remove alternative builders
#
echo
echo "Removing unused CI/CD builders..."

rm -rf \
  builders/azuredevops \
  builders/cb \
  builders/gitlab \
  builders/jenkins \
  builders/tf.cloud \
  builders/tf.local

#
# Remove files used only by alternative builder paths
#
echo
echo "Removing unused helper files..."

rm -f \
  Dockerfile \
  content.sh \
  prep.sh \
  onprem.md

#
# Verify expected GitHub builder remains
#
if [[ ! -d "builders/github" ]]; then
  echo "ERROR: builders/github is missing after cleanup."
  exit 1
fi

#
# Check for remaining references to removed paths
#
echo
echo "Checking for references to removed builders..."

grep -RIn \
  --exclude-dir=".terraform" \
  --exclude="*.tfstate*" \
  -E 'builders/(azuredevops|cb|gitlab|jenkins|tf\.cloud|tf\.local)' \
  . || true

#
# Terraform formatting
#
if command -v terraform >/dev/null 2>&1; then
  echo
  echo "Running terraform fmt..."

  terraform fmt -recursive
else
  echo
  echo "WARNING: Terraform is not installed; skipping terraform fmt."
fi

echo
echo "=================================================="
echo "Cleanup complete."
echo "=================================================="

echo
echo "Next required actions:"
echo
echo "1. Edit terraform.tfvars with your organisation values."
echo "2. Configure the gh_repos block."
echo "3. Export TF_VAR_gh_token securely."
echo "4. Review backend.tf."
echo "5. Run:"
echo
echo "   terraform init"
echo "   terraform validate"
echo "   terraform plan"
echo
echo "Backup created at:"
echo "  ${BACKUP_DIR}"
