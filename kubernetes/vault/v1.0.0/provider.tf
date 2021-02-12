provider "aws" {
  region  = var.region
  version = "~> 2.7"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}