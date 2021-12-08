locals {
  assume_role = length(var.k8s_assume_role_arn) > 0 ? true : false
}

data "aws_iam_policy_document" "cert_manager" {
  count = local.k8s_irsa_role_create && !local.assume_role ? 1 : 0

  statement {
    sid = "ChangeResourceRecordSets"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    resources = [for id in var.policy_allowed_zone_ids : "arn:aws:route53:::hostedzone/${id}"]

    effect = "Allow"
  }

  statement {
    sid = "ListResourceRecordSets"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
      "route53:ListHostedZonesByName"
    ]

    resources = [
      "*",
    ]

    effect = "Allow"
  }

  statement {
    sid = "GetBatchChangeStatus"
    actions = [
      "route53:GetChange"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cert_manager_assume" {
  count = local.k8s_irsa_role_create && local.assume_role ? 1 : 0

  statement {
    sid = "AllowAssumeCertManagerRole"

    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    resources = [
      var.k8s_assume_role_arn
    ]
  }
}

resource "aws_iam_policy" "cert_manager" {
  count = local.k8s_irsa_role_create ? 1 : 0

  name        = "${var.k8s_irsa_role_name_prefix}-${var.helm_chart_name}"
  path        = "/"
  description = "Policy for cert-manager service"

  policy = local.assume_role ? data.aws_iam_policy_document.cert_manager_assume[0].json : data.aws_iam_policy_document.cert_manager[0].json
}

data "aws_iam_policy_document" "cert_manager_irsa" {
  count = local.k8s_irsa_role_create ? 1 : 0

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
        "system:serviceaccount:${var.k8s_namespace}:${var.k8s_service_account_name}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "cert_manager" {
  count = local.k8s_irsa_role_create ? 1 : 0

  name               = "${var.k8s_irsa_role_name_prefix}-${var.helm_chart_name}"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_irsa[0].json
}

resource "aws_iam_role_policy_attachment" "cert_manager" {
  count = local.k8s_irsa_role_create ? 1 : 0

  role       = aws_iam_role.cert_manager[0].name
  policy_arn = aws_iam_policy.cert_manager[0].arn
}
