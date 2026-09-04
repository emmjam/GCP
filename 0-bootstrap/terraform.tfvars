#============================================================
#GCP ORGANISATION
#============================================================

org_id          = "132638132450"
billing_account = "billing-507309"

#============================================================
#REGIONAL CONFIGURATION
#============================================================

default_region = "europe-west2"

#============================================================
#PARENT FOLDER
#============================================================

parent_folder = "105497038508"

#============================================================
#GOOGLE GROUPS
#============================================================

groups = {
  create_required_groups = true
  create_optional_groups = true
  billing_project        = "emmjam.co.uk"

  required_groups = {
    group_org_admins           = "gcp-organization-admins@emmjam.co.uk"
    group_billing_admins       = "gcp-billing-admins@emmjam.co.uk"
    billing_data_users         = "gcp-billing-data@emmjam.co.uk"
    audit_data_users           = "gcp-audit-data@emmjam.co.uk"
    monitoring_workspace_users = "gcp-monitoring-workspace@emmjam.co.uk"
  }

  optional_groups = {
    gcp_security_reviewer    = "gcp-security-reviewer@emmjam.co.uk"
    gcp_network_viewer       = "gcp-network-viewer@emmjam.co.uk"
    gcp_scc_admin            = "gcp-scc-admin@emmjam.co.uk"
    gcp_global_secrets_admin = "gcp-global-secrets-admin@emmjam.co.uk"
    gcp_kms_admin            = "gcp-kms-admin@emmjam.co.uk"
  }
}

#============================================================
#GITHUB REPOSITORIES
#============================================================

gh_repos = {
  owner        = "emmjam"
  bootstrap    = "ian-gcp-bootstrap"
  organization = "ian-gcp-organization"
  environments = "ian-gcp-environments"
  networks     = "ian-gcp-networks"
  projects     = "ian-gcp-projects"
}

