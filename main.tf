/**
 * # AWS EKS Cert Manager Terraform module
 *
 * A Terraform module to deploy an [Cert Manager](https://cert-manager.io/) on Amazon EKS cluster.
 *
 * [![Terraform validate](https://github.com/lablabs/terraform-aws-eks-cert-manager/actions/workflows/validate.yaml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-cert-manager/actions/workflows/validate.yaml)
 * [![pre-commit](https://github.com/lablabs/terraform-aws-eks-cert-manager/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/lablabs/terraform-aws-eks-cert-manager/actions/workflows/pre-commit.yml)
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
      irsa_policy         = var.irsa_policy != null ? var.irsa_policy : try(data.aws_iam_policy_document.this[0].json, "")
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

    helm_chart_name             = "${path.module}/helm/clusterIssuer"
    helm_chart_version          = "0.1.0"
    argo_source_repo            = "https://github.com/lablabs/terraform-aws-eks-cert-manager.git"
    argo_source_path            = var.manifest_target_path
    argo_source_target_revision = var.manifest_target_revision
  }

  cluster_issuer_values = yamlencode({})

  cluster_issuer_depends_on = [module.addon]
}
