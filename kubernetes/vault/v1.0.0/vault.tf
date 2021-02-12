resource "aws_kms_key" "aws_kms_key_vault_kms_unseal" {
  description             = "Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "vault-kms-unseal"
  }
}

data "aws_iam_policy_document" "aws_iam_policy_document_vault_kms_unseal" {
  statement {
    sid       = "VaultKMSUnseal"
    effect    = "Allow"
    resources = ["${aws_kms_key.aws_kms_key_vault_kms_unseal.arn}"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
  }
}

resource "aws_iam_user" "aws_iam_user_vault_kms_unseal" {
  name = "vault-kms-unseal"
}

resource "aws_iam_policy" "aws_iam_policy_vault_kms_unseal" {
  name        = "vault-kms-unseal"
  path        = "/"
  description = "Vault unseal key"
  policy      = data.aws_iam_policy_document.aws_iam_policy_document_vault_kms_unseal.json
}

resource "aws_iam_user_policy_attachment" "aws_iam_user_policy_attachment_vault_kms_unseal" {
  user        = "${aws_iam_user.aws_iam_user_vault_kms_unseal.name}"
  policy_arn  = "${aws_iam_policy.aws_iam_policy_vault_kms_unseal.arn}"
}

resource "aws_iam_access_key" "aws_iam_access_key_vault_kms_unseal" {
  user = "${aws_iam_user.aws_iam_user_vault_kms_unseal.name}"
}

resource "kubernetes_namespace" "vault_primary" {
  metadata {
    name = "vault-primary"
  }
}

resource "kubernetes_namespace" "vault_secondary" {
  count = var.deploy_secondary == true ? 1 : 0

  metadata {
    name = "vault-secondary"
  }
}

resource "helm_release" "vault_primary" {
  name       = "vault-primary"
  repository = "https://helm.releases.hashicorp.com/"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault_primary.metadata.0.name

  values = [
    "${var.helm_values}"
  ]

  set_sensitive {
    name  = "server.ha.raft.config"
    value = templatefile("templates/config.tmpl", {
      enable_vault_ui     = var.enable_vault_ui,
      tls_disable         = var.vault_tls_disable,
      aws_kms_region      = var.region,
      aws_kms_access_key  = aws_iam_access_key.aws_iam_access_key_vault_kms_unseal.id,
      aws_kms_secret_key  = aws_iam_access_key.aws_iam_access_key_vault_kms_unseal.secret,
      aws_kms_key_id      = aws_kms_key.aws_kms_key_vault_kms_unseal.id
    })
  }
}

resource "helm_release" "vault_secondary" {
  count = var.deploy_secondary == true ? 1 : 0

  name       = "vault-secondary"
  repository = "https://helm.releases.hashicorp.com/"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault_secondary.0.metadata.0.name

  values = [
    "${var.helm_values}"
  ]

  set_sensitive {
    name  = "server.ha.raft.config"
    value = templatefile("templates/config.tmpl", {
      enable_vault_ui     = var.enable_vault_ui,
      tls_disable         = var.vault_tls_disable,
      aws_kms_region      = var.region,
      aws_kms_access_key  = aws_iam_access_key.aws_iam_access_key_vault_kms_unseal.id,
      aws_kms_secret_key  = aws_iam_access_key.aws_iam_access_key_vault_kms_unseal.secret,
      aws_kms_key_id      = aws_kms_key.aws_kms_key_vault_kms_unseal.id
    })
  }
}

resource "kubernetes_secret" "vault_tls_primary" {
  metadata {
    name      = "tls"
    namespace = kubernetes_namespace.vault_primary.metadata.0.name
  }

  data = {
    "tls_crt" = tls_self_signed_cert.primary_cert.cert_pem,
    "tls_key" = tls_private_key.cert.private_key_pem
  }
}

resource "kubernetes_secret" "vault_tls_secondary" {
  count = var.deploy_secondary == true ? 1 : 0

  metadata {
    name      = "tls"
    namespace = kubernetes_namespace.vault_secondary.0.metadata.0.name
  }

  data = {
    "tls_crt" = tls_self_signed_cert.secondary_cert.0.cert_pem,
    "tls_key" = tls_private_key.cert.private_key_pem
  }
}