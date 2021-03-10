# Required module inputs

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "cluster_identity_oidc_issuer" {
  type        = string
  description = "The OIDC Identity issuer for the cluster"
}

variable "cluster_identity_oidc_issuer_arn" {
  type        = string
  description = "The OIDC Identity issuer ARN for the cluster that can be used to associate IAM roles with a service account"
}

variable "policy_allowed_zone_ids" {
  type        = list(string)
  default     = ["*"]
  description = "List of the Route53 zone ids for service account IAM role access"
}

# cert-manager

variable "enabled" {
  type        = bool
  default     = true
  description = "Variable indicating whether deployment is enabled"
}

variable "cluster_issuer_enabled" {
  type        = bool
  default     = false
  description = "Variable indicating whether default ClusterIssuer CRD is enabled"
}


# Helm

variable "helm_chart_name" {
  type        = string
  default     = "cert-manager"
  description = "Helm chart name to be installed"
}

variable "helm_chart_version" {
  type        = string
  default     = "v1.2.0"
  description = "Version of the Helm chart"
}

variable "helm_release_name" {
  type        = string
  default     = "cert-manager"
  description = "Helm release name"
}

variable "helm_repo_url" {
  type        = string
  default     = "https://charts.jetstack.io"
  description = "Helm repository"
}

# K8S

variable "k8s_create_namespace" {
  type        = bool
  default     = false
  description = "Whether to create k8s namespace with name defined by `k8s_namespace`"
}

variable "k8s_namespace" {
  type        = string
  default     = "kube-system"
  description = "The k8s namespace in which the cert-manager service account has been created"
}

variable "k8s_service_account_name" {
  type        = string
  default     = "cert-manager"
  description = "The k8s cert-manager service account name"
}

variable "mod_dependency" {
  default     = null
  description = "Dependence variable binds all AWS resources allocated by this module, dependent modules reference this variable"
}

variable "settings" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values, see https://artifacthub.io/packages/helm/jetstack/cert-manager"
}

variable "cluster_issuer_settings" {
  type        = map(any)
  default     = {}
  description = "Additional settings which will be passed to the Helm chart cluster_issuer values, see https://github.com/lablabs/terraform-aws-eks-aws-cert-manager/blob/master/helm/defaultClusterIssuer/values.yaml"
}
