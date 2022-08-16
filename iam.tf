locals {
  irsa_role_create = var.enabled && var.rbac_create && var.service_account_create && var.irsa_role_create
}

data "aws_iam_policy_document" "this" {
  count = local.irsa_role_create ? 1 : 0

  dynamic "statement" {
    for_each = var.irsa_policy_enabled ? toset(["true"]) : []
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
    for_each = var.irsa_policy_enabled ? toset(["true"]) : []
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
    for_each = var.irsa_policy_enabled ? toset(["true"]) : []
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
    for_each = var.irsa_assume_role_enabled ? toset(["true"]) : []
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

resource "aws_iam_policy" "this" {
  count = local.irsa_role_create && (var.irsa_policy_enabled || var.irsa_policy_enabled) ? 1 : 0

  name        = "${var.irsa_role_name_prefix}-${var.helm_release_name}"
  path        = "/"
  description = "Policy for cert-manager service"
  policy      = data.aws_iam_policy_document.this[0].json

  tags = var.irsa_tags
}

data "aws_iam_policy_document" "this_irsa" {
  count = local.irsa_role_create ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.cluster_identity_oidc_issuer_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.cluster_identity_oidc_issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "this" {
  count = local.irsa_role_create ? 1 : 0

  name               = "${var.irsa_role_name_prefix}-${var.helm_release_name}"
  assume_role_policy = data.aws_iam_policy_document.this_irsa[0].json

  tags = var.irsa_tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count = local.irsa_role_create ? 1 : 0

  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_iam_role_policy_attachment" "this_additional" {
  for_each = local.irsa_role_create ? var.irsa_additional_policies : {}

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}
