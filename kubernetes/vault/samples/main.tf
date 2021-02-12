module "vault" {
  source = "github.com/gsalgadoartola/terraform-modules//kubernetes/vault/v1.0.0"

  region              = "us-east-1"
  initial_node_count  = "1"
  primary_hostname    = "vault-primary"
  secondary_hostname  = "vault-secondary"
  domain              = "svc"
  deploy_secondary    = false
  enable_vault_ui     = true
  vault_tls_disable   = false
  helm_values         = file("values.yaml")
}