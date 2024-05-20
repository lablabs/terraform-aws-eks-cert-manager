locals {
  default_cluster_issuer_argo_application_values = {
    "apiVersion" : var.argo_apiversion
    "spec" : {
      "project" : var.argo_project
      "source" : {
        "repoURL" : "https://github.com/lablabs/terraform-aws-eks-cert-manager.git"
        "path" : "helm/defaultClusterIssuer"
        "targetRevision" : var.manifest_target_revision
        "helm" : {
          "releaseName" : "${var.helm_release_name}-default-cluster-issuer"
          "parameters" : [for k, v in var.cluster_issuer_settings : tomap({ "forceString" : true, "name" : k, "value" : v })]
          "values" : var.enabled ? data.utils_deep_merge_yaml.default_cluster_issuer_values[0].output : ""
        }
      }
      "destination" : {
        "server" : var.argo_destination_server
        "namespace" : var.namespace
      }
      "syncPolicy" : var.argo_sync_policy
      "info" : var.argo_info
    }
  }
}

data "utils_deep_merge_yaml" "default_cluster_issuer_values" {
  count = var.enabled ? 1 : 0
  input = compact([
    var.cluster_issuers_values
  ])
}

resource "helm_release" "default_cluster_issuer" {
  count = var.enabled && !var.argo_enabled && var.cluster_issuer_enabled ? 1 : 0

  chart     = "${path.module}/helm/defaultClusterIssuer"
  name      = "${var.helm_release_name}-cluster-issuer"
  namespace = var.namespace

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
    helm_release.this
  ]
}

resource "kubernetes_manifest" "default_cluster_issuer_argo_application" {
  count = var.enabled && var.argo_enabled && !var.argo_helm_enabled && var.cluster_issuer_enabled ? 1 : 0
  manifest = merge(
    {
      "kind" = "Application"
      "metadata" = merge(
        local.argo_application_metadata,
        { "name" = "${var.helm_release_name}-default-cluster-issuer" },
        { "namespace" = var.argo_namespace },
      )
    },
    local.default_cluster_issuer_argo_application_values
  )
  depends_on = [
    kubernetes_manifest.this
  ]
}

resource "helm_release" "default_cluster_issuer_argo_application" {
  count = var.enabled && var.argo_enabled && var.argo_helm_enabled && var.cluster_issuer_enabled ? 1 : 0

  chart     = "${path.module}/helm/argocd-application"
  name      = "${var.helm_release_name}-default-cluster-issuer"
  namespace = var.argo_namespace

  values = compact([
    yamlencode(local.default_cluster_issuer_argo_application_values),
    yamlencode(local.argo_application_metadata)
  ])
}
