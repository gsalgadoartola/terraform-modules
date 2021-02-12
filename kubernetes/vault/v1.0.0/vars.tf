variable "region" {
  type        = string
  description = "AWS region"
}

variable "initial_node_count" {
  type        = string
  description = "Inital node count for kubernetes cluster"
  default     = "1"
}

variable "primary_hostname" {
  type        = string
  description = "Hostname for self-signed certificate"
  default     = "vault-primary"
}

variable "secondary_hostname" {
  type        = string
  description = "Hostname for self-signed certificate"
  default     = "vault-secondary"
}

variable "domain" {
  type        = string
  description = "Domain for self-signed certificate"
}

variable "deploy_secondary" {
  type        = bool
  description = "Controls whether or not to deploy a second vault in a separate namespace"
  default     = false
}

variable "enable_vault_ui" {
  type        = bool
  description = "Controls whether to enable the UI for Vault or not"
  default     = true
}

variable "vault_tls_disable" {
  type        = bool
  description = "Controls whether to disable tls for Vault or not"
  default     = false
}

variable "helm_values" {
  type        = string
  description = "Helm chart values"
}
