# IMPORTANT: Add addon specific variables here
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
