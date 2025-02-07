locals {
  values = yamlencode({
    "installCRDs" : true,
    "global" : {
      "rbac" : {
        "create" : var.rbac_create
      }
    }
    "serviceAccount" : {
      "create" : var.service_account_create
      "name" : var.service_account_name
      "annotations" : {
        "eks.amazonaws.com/role-arn" : local.irsa_role_create ? aws_iam_role.this[0].arn : ""
      }
    }
  })
  # info about default cluster issuer for cert manager chart
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
    var.values,
    var.cluster_issuer_enabled ? local.cluster_issuers_values : ""
  ])
}
