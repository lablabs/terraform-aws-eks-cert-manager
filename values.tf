locals {
  values = yamlencode({
    "installCRDs" : true,
    "rbac" : {
      "create" : var.rbac_create
    }
    "serviceAccount" : {
      "create" : var.service_account_create
      "name" : var.service_account_name
      "annotations" : {
        "eks.amazonaws.com/role-arn" : local.irsa_role_create ? aws_iam_role.this[0].arn : ""
      }
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
