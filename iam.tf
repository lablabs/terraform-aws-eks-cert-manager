locals {
  irsa_policy_enabled = var.irsa_policy_enabled != null ? var.irsa_policy_enabled : coalesce(var.irsa_assume_role_enabled, false) == false
}

data "aws_iam_policy_document" "this" {
  count = var.enabled && var.irsa_policy == null && local.irsa_policy_enabled ? 1 : 0

  dynamic "statement" {
    for_each = local.irsa_policy_enabled ? toset(["true"]) : []
    content {
      sid    = "ChangeResourceRecordSets"
      effect = "Allow"
      actions = [
        "route53:ChangeResourceRecordSets",
      ]
      resources = formatlist(
        "arn:aws:route53:::hostedzone/%s",
        var.policy_allowed_zone_ids
      )

    }
  }

  dynamic "statement" {
    for_each = local.irsa_policy_enabled ? toset(["true"]) : []
    content {
      sid    = "ListResourceRecordSets"
      effect = "Allow"
      actions = [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ListTagsForResource",
        "route53:ListHostedZonesByName"
      ]
      resources = [
        "*"
      ]
    }
  }

  dynamic "statement" {
    for_each = local.irsa_policy_enabled ? toset(["true"]) : []
    content {
      sid    = "GetBatchChangeStatus"
      effect = "Allow"
      actions = [
        "route53:GetChange"
      ]
      resources = [
        "*"
      ]
    }
  }

  dynamic "statement" {
    for_each = coalesce(var.irsa_assume_role_enabled, false) ? toset(["true"]) : []
    content {
      sid    = "AllowAssumeCertManagerRole"
      effect = "Allow"
      actions = [
        "sts:AssumeRole"
      ]
      resources = var.irsa_assume_role_arns
    }
  }
}
