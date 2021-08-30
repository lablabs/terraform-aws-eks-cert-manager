locals {
  k8s_irsa_role_create = var.enabled && var.k8s_rbac_create && var.k8s_service_account_create && var.k8s_irsa_role_create

  values = yamlencode({
    "installCRDs" : true,
    "rbac" : {
      "create" : var.k8s_rbac_create
    }
    "serviceAccount" : {
      "create" : var.k8s_service_account_create
      "name" : var.k8s_service_account_name
      "annotations" : {
        "eks.amazonaws.com/role-arn" : local.k8s_irsa_role_create ? aws_iam_role.cert_manager[0].arn : ""
      }
    }
  })

  cluster_issuers_values = yamlencode({
    "ingressShim" : {
      "defaultIsuserName" : "default"
      "defaultIssuerKind" : "ClusterIssuer"
      "defaultIssuerGroup" : "cert-manager.io"
    }
  })
}

data "aws_region" "current" {}

data "utils_deep_merge_yaml" "values" {
  count = var.enabled ? 1 : 0
  input = compact([
    local.values,
    var.cluster_issuer_enabled ? local.cluster_issuers_values : "",
    var.values
  ])
}

resource "helm_release" "cert_manager" {
  count = var.enabled ? 1 : 0

  chart            = var.helm_chart_name
  create_namespace = var.helm_create_namespace
  namespace        = var.k8s_namespace
  name             = var.helm_release_name
  version          = var.helm_chart_version
  repository       = var.helm_repo_url

  values = [
    data.utils_deep_merge_yaml.values[0].output
  ]

  dynamic "set" {
    for_each = var.settings
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "time_sleep" "default_cluster_issuer" {
  count = var.enabled && var.cluster_issuer_enabled ? 1 : 0

  create_duration = "30s"

  depends_on = [
    helm_release.cert_manager
  ]
}

resource "helm_release" "default_cluster_issuer" {
  count = var.enabled && var.cluster_issuer_enabled ? 1 : 0

  chart     = "${path.module}/helm/defaultClusterIssuer"
  name      = "cert-manger-cluster-issuer"
  namespace = var.k8s_namespace

  values = [
    var.cluster_issuers_values
  ]

  dynamic "set" {
    for_each = var.cluster_issuer_settings
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [
    time_sleep.default_cluster_issuer[0]
  ]
}
