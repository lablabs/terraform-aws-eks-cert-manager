locals {
  irsa_policy_enabled = var.irsa_policy_enabled != null ? var.irsa_policy_enabled : true
}

data "aws_iam_policy_document" "this" {
  count = var.enabled && var.irsa_policy == null && local.irsa_policy_enabled ? 1 : 0
  #https://cert-manager.io/docs/configuration/acme/dns01/route53/
  #checkov:skip=CKV_AWS_356
  statement {
    sid    = "ResourceRecordSets"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = formatlist(
      "arn:aws:route53:::hostedzone/%s",
      var.policy_allowed_zone_ids
    )
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
      values   = ["TXT"]
    }
  }

  statement {
    sid    = "ListResourceRecordSets"
    effect = "Allow"
    actions = [
      "route53:ListHostedZonesByName"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "GetBatchChangeStatus"
    effect = "Allow"
    actions = [
      "route53:GetChange"
    ]
    resources = [
      "arn:aws:route53:::change/*"
    ]
  }
}
