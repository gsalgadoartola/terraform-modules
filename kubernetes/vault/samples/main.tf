module "vault" {
  source = "github.com/gsalgadoartola/terraform-modules//kubernetes/vault/v1.0.0"

  region              = var.region
  initial_node_count  = var.initial_node_count
  primary_hostname    = var.primary_hostname
  secondary_hostname  = var.secondary_hostname
  domain              = var.domain
  deploy_secondary    = var.deploy_secondary
  enable_vault_ui     = var.enable_vault_ui
  vault_tls_disable   = var.vault_tls_disable
  helm_values         = file("values.yaml")
}