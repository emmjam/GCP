#!/bin/bash
set -euo pipefail
cd /home/ian/Projects/GCP/GCP/IAN
source /home/ian/Projects/GCP/ENVS_IAN.sh
BOOTSTRAP_DIR="${WDIR}/0-bootstrap"
SOURCE_TFVARS="${BOOTSTRAP_DIR}/terraform.example.tfvars"
TARGET_TFVARS="${BOOTSTRAP_DIR}/terraform.tfvars"

####### VARIABLES
# GCP ORGANISATION
ORG_ID="${ORG_ID}"
BILLING_ACCOUNT="${BILLING_ID}"
DEFAULT_REGION="${REGION}"
PARENT_FOLDER="${PARENT_FOLDER_ID}"  #Leave EMPTY to deploy directly beneath the organisation.

# GOOGLE GROUPS
CREATE_REQUIRED_GROUPS="true"
BILLING_PROJECT="${BILLING_PROJECT}"
GROUP_ORG_ADMINS="gcp-organization-admins@${DOMAIN}"
GROUP_BILLING_ADMINS="gcp-billing-admins@${DOMAIN}"
GROUP_BILLING_DATA_USERS="gcp-billing-data@${DOMAIN}"
GROUP_AUDIT_DATA_USERS="gcp-audit-data@${DOMAIN}"
GROUP_MONITORING_WORKSPACE_USERS="gcp-monitoring-workspace@${DOMAIN}"

CREATE_OPTIONAL_GROUPS="true"
GROUP_SECURITY_REVIEWER="gcp-security-reviewer@${DOMAIN}"
GROUP_NETWORK_VIEWER="gcp-network-viewer@${DOMAIN}"
GROUP_SCC_ADMIN="gcp-scc-admin@${DOMAIN}"
GROUP_GLOBAL_SECRETS_ADMIN="gcp-global-secrets-admin@${DOMAIN}"
GROUP_KMS_ADMIN="gcp-kms-admin@${DOMAIN}"

# GITHUB
GITHUB_OWNER="${GH_OWNER}"
GITHUB_BOOTSTRAP_REPO="${GH_REPO_PREFIX}-bootstrap"
GITHUB_ORGANIZATION_REPO="${GH_REPO_PREFIX}-organization"
GITHUB_ENVIRONMENTS_REPO="${GH_REPO_PREFIX}-environments"
GITHUB_NETWORKS_REPO="${GH_REPO_PREFIX}-networks"
GITHUB_PROJECTS_REPO="${GH_REPO_PREFIX}-projects"

#################################################################

#------------------------------------------------------------
#VALIDATE DIRECTORY
#------------------------------------------------------------

if [[ ! -d "${BOOTSTRAP_DIR}" ]]; then

echo "ERROR: Bootstrap directory not found:"
echo "  ${BOOTSTRAP_DIR}"
exit 1

fi

#------------------------------------------------------------
#VALIDATE SOURCE FILE
#------------------------------------------------------------

if [[ ! -f "${SOURCE_TFVARS}" ]]; then

echo "ERROR: Source tfvars file not found:"
echo "  ${SOURCE_TFVARS}"
exit 1

fi

#------------------------------------------------------------
#VALIDATE REQUIRED VALUES
#------------------------------------------------------------

REQUIRED_VALUES=(
"ORG_ID"
"BILLING_ACCOUNT"
"DEFAULT_REGION"
"GITHUB_OWNER"
"GITHUB_BOOTSTRAP_REPO"
"GITHUB_ORGANIZATION_REPO"
"GITHUB_ENVIRONMENTS_REPO"
"GITHUB_NETWORKS_REPO"
"GITHUB_PROJECTS_REPO"
)

for VARIABLE_NAME in "${REQUIRED_VALUES[@]}"; do

if [[ -z "${!VARIABLE_NAME}" ]]; then

    echo "ERROR: Required variable is empty:"
    echo "  ${VARIABLE_NAME}"

    exit 1

fi

done

#------------------------------------------------------------
#VALIDATE BILLING PROJECT
#------------------------------------------------------------

if [[ "${CREATE_REQUIRED_GROUPS}" == "true" ||
"${CREATE_OPTIONAL_GROUPS}" == "true" ]]; then

if [[ -z "${BILLING_PROJECT}" ]]; then

    echo "ERROR:"
    echo "BILLING_PROJECT must be specified when Terraform"
    echo "is configured to create Google Groups."

    exit 1

fi

fi

#------------------------------------------------------------
#BACK UP EXISTING terraform.tfvars
#------------------------------------------------------------

if [[ -f "${TARGET_TFVARS}" ]]; then

BACKUP_FILE="${TARGET_TFVARS}.backup-$(date +%Y%m%d-%H%M%S)"

echo "Backing up existing terraform.tfvars:"
echo "  ${BACKUP_FILE}"

cp "${TARGET_TFVARS}" "${BACKUP_FILE}"

fi

#------------------------------------------------------------
#CREATE terraform.tfvars
#------------------------------------------------------------

echo
echo "Creating:"
echo " ${TARGET_TFVARS}"
echo

cat > "${TARGET_TFVARS}" <<EOF
#============================================================
#GCP ORGANISATION
#============================================================

org_id = "${ORG_ID}"
billing_account = "${BILLING_ACCOUNT}"

#============================================================
#REGIONAL CONFIGURATION
#============================================================

default_region = "${DEFAULT_REGION}"

#============================================================
#PARENT FOLDER
#============================================================

parent_folder = "${PARENT_FOLDER}"

#============================================================
#GOOGLE GROUPS
#============================================================

groups = {
create_required_groups = ${CREATE_REQUIRED_GROUPS}
create_optional_groups = ${CREATE_OPTIONAL_GROUPS}
billing_project = "${BILLING_PROJECT}"

required_groups = {
group_org_admins = "${GROUP_ORG_ADMINS}"
group_billing_admins = "${GROUP_BILLING_ADMINS}"
billing_data_users = "${GROUP_BILLING_DATA_USERS}"
audit_data_users = "${GROUP_AUDIT_DATA_USERS}"
monitoring_workspace_users = "${GROUP_MONITORING_WORKSPACE_USERS}"
}

optional_groups = {
gcp_security_reviewer = "${GROUP_SECURITY_REVIEWER}"
gcp_network_viewer = "${GROUP_NETWORK_VIEWER}"
gcp_scc_admin = "${GROUP_SCC_ADMIN}"
gcp_global_secrets_admin = "${GROUP_GLOBAL_SECRETS_ADMIN}"
gcp_kms_admin = "${GROUP_KMS_ADMIN}"
}
}

#============================================================
#GITHUB REPOSITORIES
#============================================================

gh_repos = {
owner = "${GITHUB_OWNER}"
bootstrap = "${GITHUB_BOOTSTRAP_REPO}"
organization = "${GITHUB_ORGANIZATION_REPO}"
environments = "${GITHUB_ENVIRONMENTS_REPO}"
networks = "${GITHUB_NETWORKS_REPO}"
projects = "${GITHUB_PROJECTS_REPO}"
}

EOF

#------------------------------------------------------------
#FORMAT terraform.tfvars
#------------------------------------------------------------

if command -v terraform >/dev/null 2>&1; then

echo "Running terraform fmt..."

terraform -chdir="${BOOTSTRAP_DIR}" fmt terraform.tfvars

else

echo
echo "WARNING: Terraform was not found."
echo "Skipping terraform fmt."

fi

#------------------------------------------------------------
#DISPLAY RESULT
#------------------------------------------------------------

echo
echo "============================================================"
echo "terraform.tfvars successfully created"
echo "============================================================"
echo

echo "Location:"
echo " ${TARGET_TFVARS}"

echo

echo "Configured values:"

echo " Organisation ID: ${ORG_ID}"

echo " Billing Account: ${BILLING_ACCOUNT}"

echo " Default Region: ${DEFAULT_REGION}"

echo " Parent Folder: ${PARENT_FOLDER:-<organisation root>}"

echo " GitHub Owner: ${GITHUB_OWNER}"

echo

echo "Next steps:"
echo

echo " cd ${BOOTSTRAP_DIR}"

echo " terraform init"

echo " terraform validate"

echo " terraform plan"
echo
