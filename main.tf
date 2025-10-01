/**
 * # AWS EKS Cert Manager Terraform module
 *
 * A Terraform module to deploy an [Cert Manager](https://cert-manager.io/) on Amazon EKS cluster.
 *
 * [![Terraform validate](https://github.com/lablabs/terraform-aws-eks-cert-manager/actions/workflows/validate.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-cert-manager/actions/workflows/validate.yaml)
 * [![pre-commit](https://github.com/lablabs/terraform-aws-eks-cert-manager/actions/workflows/pre-commit.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-cert-manager/actions/workflows/pre-commit.yaml)
 */
locals {
  addon = {
    name      = "cert-manager"
    namespace = "kube-system"

    helm_chart_version = "1.17.1"
    helm_repo_url      = "https://charts.jetstack.io"
  }

  addon_irsa = {
    (local.addon.name) = {
      irsa_policy_enabled = local.irsa_policy_enabled
      irsa_policy         = var.irsa_policy != null ? var.irsa_policy : jsonencode(local.irsa_policy)
    }
  }

  addon_values = yamlencode({
    crds = {
      enabled = var.crds_enabled
    }
    global = {
      rbac = {
        create = module.addon-irsa[local.addon.name].rbac_create
      }
    }
    serviceAccount = {
      create = module.addon-irsa[local.addon.name].service_account_create
      name   = module.addon-irsa[local.addon.name].service_account_name
      annotations = module.addon-irsa[local.addon.name].irsa_role_enabled ? {
        "eks.amazonaws.com/role-arn" = module.addon-irsa[local.addon.name].iam_role_attributes.arn
      } : tomap({})
    }
    ingressShim = var.cluster_issuer_enabled ? {
      defaultIssuerName  = "default"
      defaultIssuerKind  = "ClusterIssuer"
      defaultIssuerGroup = "cert-manager.io"
    } : tomap({})
  })

  addon_depends_on = []

  cluster_issuer = {
    name = "cert-manager-cluster-issuer"

    helm_chart_version = var.cluster_issuer_helm_chart_version != null ? var.cluster_issuer_helm_chart_version : var.manifest_target_revision
    helm_repo_url      = var.cluster_issuer_helm_repo_url != null ? var.cluster_issuer_helm_repo_url : "https://github.com/lablabs/terraform-aws-eks-cert-manager.git"
    argo_enabled       = var.cluster_issuer_argo_enabled != null ? var.cluster_issuer_argo_enabled : try(length(module.addon.kubernetes_application_attributes) > 0, true)
    argo_helm_enabled  = var.cluster_issuer_argo_helm_enabled != null ? var.cluster_issuer_argo_helm_enabled : try(length(module.addon.kubernetes_application_attributes) > 0, true)
    argo_source_path   = var.cluster_issuer_argo_source_path != null ? var.cluster_issuer_argo_source_path : var.manifest_target_path
  }

  cluster_issuer_values = yamlencode({})

  cluster_issuer_depends_on = [
    module.addon
  ]
}
