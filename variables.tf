# IMPORTANT: Add addon specific variables here
variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "crds_enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating CRD resources."
}

variable "cluster_issuer_enabled" {
  type        = bool
  default     = false
  description = "Variable indicating whether default ClusterIssuer CRD is enabled"
}

variable "policy_allowed_zone_ids" {
  type        = list(string)
  default     = ["*"]
  description = "List of the Route53 zone ids for service account IAM role access"
}

variable "manifest_target_revision" {
  type        = string
  default     = "v2.1.1" #FIXME: update revision before release
  description = "Manifest target revision to deploy from"
}

variable "manifest_target_path" {
  type        = string
  default     = "helm/clusterIssuer"
  description = "Manifest target path in projects repository"
}
