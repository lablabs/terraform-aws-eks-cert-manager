module "example" {
  source = "../../"

  cluster_issuer_enabled           = true
  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn

  k8s_assume_role_enabled = true
  k8s_assume_role_arns = [
    "arn"
  ]

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

  cluster_issuers_values = yamlencode({
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
  })
}

module "disabled" {
  source = "../../"

  enabled = false

  cluster_identity_oidc_issuer     = module.eks_cluster.eks_cluster_identity_oidc_issuer
  cluster_identity_oidc_issuer_arn = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
}
