1. install terraform and gcp_cli
2. create initial github repo and clone into it:  https://github.com/GoogleCloudPlatform/pbmm-on-gcp-onboarding/blob/main/0-bootstrap/README-GitHub.md
3. Create other git repos:
for r in ian-gcp-bootstrap ian-gcp-networks ian-gcp-environments ian-gcp-organization ian-gcp-projects; do
> gh repo create $r --private
> done
4. Run the 0-bootstrap script to remove unnecessary files and rename needed files
5. Run the 0-tfvars script to set variables
6. Update policy-library/policies/constraints/serviceusage_allow_basic_apis.yaml and add  alphabetically
   - cloudidentity.googleapis.com
   - networksecurity.googleapis.com
7. Create the tfstate bucket: source ENV_IAN.sh
       gcloud storage buckets create gs://${TFSTATE_BUCKET_NAME} --location EU
       gcloud storage buckets update gs://${TFSTATE_BUCKET_NAME} --versioning
8. Configure the gh_repos block.
9. export TF_VAR_gh_token=$(cat ~/github_token)
10. Review backend.tf.
11. Run:

   terraform init    (terraform init --reconfigure)
   terraform validate
   terraform plan
