locals {
  values_cert_manager = yamlencode({
    "installCRDs" : true,
    "serviceAccount" : {
      "name" : var.k8s_service_account_name
      "annotations" : {
        "eks.amazonaws.com/role-arn" : aws_iam_role.cert_manager[0].arn
      }
    }
  })

  values_cert_manager_issuer = yamlencode({
    "installCRDs" : true
    "serviceAccount" : {
      "name" : var.k8s_service_account_name
      "annotations" : {
        "eks.amazonaws.com/role-arn" : aws_iam_role.cert_manager[0].arn
      }
    }
    "ingressShim" : {
      "defaultIsuserName" : "default"
      "defaultIssuerKind" : "ClusterIssuer"
      "defaultIssuerGroup" : "cert-manager.io"
    }
  })
}

data "utils_deep_merge_yaml" "values_cert_manager" {
  count = var.enabled ? 1 : 0
  input = compact([
    local.values_cert_manager,
    var.values
  ])
}

data "utils_deep_merge_yaml" "values_cert_manager_issuer" {
  count = var.enabled ? 1 : 0
  input = compact([
    local.values_cert_manager_issuer,
    var.values
  ])
}

data "aws_region" "current" {}

resource "helm_release" "cert_manager" {
  count = var.enabled && !var.cluster_issuer_enabled ? 1 : 0

  repository       = var.helm_repo_url
  chart            = var.helm_chart_name
  version          = var.helm_chart_version
  name             = var.helm_release_name
  namespace        = var.k8s_namespace
  create_namespace = var.k8s_create_namespace

  values = [
    data.utils_deep_merge_yaml.values_cert_manager[0].output
  ]

  dynamic "set" {
    for_each = var.settings
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "helm_release" "cert_manager_default_cluster_issuer" {
  count = var.enabled && var.cluster_issuer_enabled ? 1 : 0

  repository       = var.helm_repo_url
  chart            = var.helm_chart_name
  version          = var.helm_chart_version
  name             = var.helm_release_name
  namespace        = var.k8s_namespace
  create_namespace = var.k8s_create_namespace
  wait             = true

  values = [
    data.utils_deep_merge_yaml.values_cert_manager_issuer[0].output
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
    helm_release.cert_manager_default_cluster_issuer
  ]
}

resource "helm_release" "default_cluster_issuer" {
  count = var.enabled && var.cluster_issuer_enabled ? 1 : 0

  chart     = "${path.module}/helm/defaultClusterIssuer"
  name      = "cert-manger-cluster-issuer"
  namespace = var.k8s_namespace

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
