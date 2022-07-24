locals {
  values = yamlencode({
    "installCRDs" : true,
    "rbac" : {
      "create" : var.k8s_rbac_create
    }
    "serviceAccount" : {
      "create" : var.k8s_service_account_create
      "name" : var.k8s_service_account_name
      "annotations" : {
        "eks.amazonaws.com/role-arn" : local.k8s_irsa_role_create ? aws_iam_role.this[0].arn : ""
      }
    }
  })

  cluster_issuers_values = yamlencode({
    "ingressShim" : {
      "defaultIssuerName" : "default"
      "defaultIssuerKind" : "ClusterIssuer"
      "defaultIssuerGroup" : "cert-manager.io"
    }
  })
}

data "utils_deep_merge_yaml" "values" {
  count = var.enabled ? 1 : 0
  input = compact([
    local.values,
    var.cluster_issuer_enabled ? local.cluster_issuers_values : "",
    var.values
  ])
}

data "utils_deep_merge_yaml" "default_cluster_issuer_values" {
  count = var.enabled ? 1 : 0
  input = compact([
    var.cluster_issuers_values
  ])
}
