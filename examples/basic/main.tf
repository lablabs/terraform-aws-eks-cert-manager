locals {
  values = yamlencode({
    "podDnsPolicy" : "None"
    "podDnsConfig" : {
      "nameservers" : [
        "1.1.1.1",
        "8.8.8.8"
      ]
    }
    "securityContext" : {
      "fsGroup" : 1001
      "runAsUser" : 1001
    }
  })
  cluster_issuer_values = yamlencode({
    "route53" : {
      "default" : {
        "region" : "eu-central-1"
        "dnsZones" : [
          "foo.examaple.com",
        ]
        "acme" : {
          "email" : "xyz@lablabs.io"
          "server" : "https://acme-v02.api.letsencrypt.org/directory"
        }
      }
      "shared" : {
        "region" : "eu-central-1"
        "roleArn" : "arn"
        "dnsZones" : [
          "example.com"
        ]
        "acme" : {
          "email" : "xyz@lablabs.io"
          "server" : "https://acme-v02.api.letsencrypt.org/directory"
        }
      }
    }
    "http" : {
      "default-http" : {
        "ingressClassName" : "nginx"
        "acme" : {
          "email" : "xyz@lablabs.io"
          "server" : "https://acme-v02.api.letsencrypt.org/directory"
        }
      }
    }
    "cloudflare" : {
      "default-cloudflare" : {
        "apiTokenSecretRef" : {
          "name" : "add_your_name_here"
          "key" : "add_you_token_here"
        }
        "acme" : {
          "email" : "xyz@lablabs.io"
          "server" : "https://acme-v02.api.letsencrypt.org/directory"
          "privateKeySecretRef" : {
            "name" : "add_secret_name_with_private_key"
          }
        }
        "dnsZones" : [
          "example.com"
        ]
      }
    }
  })
}

module "cert_manager_disabled" {
  source = "../../"

  enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
}

module "cert_manager_without_irsa_role" {
  source = "../../"

  irsa_role_create                 = false
  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
}

module "cert_manager_without_irsa_policy" {
  source = "../../"

  enabled = false

  irsa_policy_enabled              = false
  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
}

module "cert_manager_assume" {
  source = "../../"

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  irsa_assume_role_enabled = true
  irsa_assume_role_arns = [
    "arn"
  ]
}

module "cert_manager_helm" {
  source = "../../"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  helm_release_name = "cert-manager-helm"
  namespace         = "cert-manager-helm"

  cluster_issuer_enabled = true
  values                 = local.values
  cluster_issuer_values  = local.cluster_issuer_values

  helm_wait_for_jobs = true
}

module "cert_manager_argo_kubernetes" {
  source = "../../"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  helm_release_name = "cert-manager-argo-kubernetes"
  namespace         = "cert-manager-argo-kubernetes"

  cluster_issuer_enabled = true
  values                 = local.values
  cluster_issuer_values  = local.cluster_issuer_values

  argo_kubernetes_manifest_wait_fields = {
    "status.sync.status" : "Synced"
    "status.health.status" : "Healthy"
    "status.operationState.phase" : "Succeeded"
  }

  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
  }
}

module "cert_manager_argo_helm" {
  source = "../../"

  enabled           = true
  argo_enabled      = true
  argo_helm_enabled = true

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  helm_release_name = "cert-manager-argo-helm"
  namespace         = "cert-manager-argo-helm"

  cluster_issuer_enabled = true
  values                 = local.values
  cluster_issuer_values  = local.cluster_issuer_values

  argo_namespace = "argo"
  argo_sync_policy = {
    "automated" : {}
    "syncOptions" = ["CreateNamespace=true"]
    "retry" : {
      "limit" : 5
      "backoff" : {
        "duration" : "30s"
        "factor" : 2
        "maxDuration" : "3m0s"
      }
    }
  }
}
