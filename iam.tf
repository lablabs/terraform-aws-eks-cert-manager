locals {
  irsa_policy_enabled = var.irsa_policy_enabled != null ? var.irsa_policy_enabled : true
  irsa_policy = {
    #https://cert-manager.io/docs/configuration/acme/dns01/route53/
    #checkov:skip=CKV_AWS_356
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ResourceRecordSets"
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets",
        ]
        Resource = formatlist(
          "arn:aws:route53:::hostedzone/%s",
          var.policy_allowed_zone_ids
        )
        Condition = {
          "ForAllValues:StringEquals" = {
            "route53:ChangeResourceRecordSetsRecordTypes" = ["TXT"]
          }
        }
      },
      {
        Sid    = "ListResourceRecordSets"
        Effect = "Allow"
        Action = [
          "route53:ListHostedZonesByName"
        ]
        Resource = "*"
      },
      {
        Sid    = "GetBatchChangeStatus"
        Effect = "Allow"
        Action = [
          "route53:GetChange"
        ]
        Resource = "arn:aws:route53:::change/*"
      }
    ]
  }
}
