resource "helm_release" "this" {
  count = var.enabled && !var.argo_application_enabled ? 1 : 0

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

  create_duration = "120s"

  depends_on = [
    helm_release.this
  ]
}

resource "helm_release" "default_cluster_issuer" {
  count = var.enabled && var.cluster_issuer_enabled ? 1 : 0

  chart     = "${path.module}/helm/defaultClusterIssuer"
  name      = "${var.helm_release_name}-cluster-issuer"
  namespace = var.k8s_namespace

  values = [
    data.utils_deep_merge_yaml.default_cluster_issuer_values[0].output
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
