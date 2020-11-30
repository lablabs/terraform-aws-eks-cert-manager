data "aws_region" "current" {}

resource "helm_release" "cert_manager" {
  count = var.enabled && ! var.cluster_issuer_enabled ? 1 : 0

  repository       = var.helm_repo_url
  chart            = var.helm_chart_name
  version          = var.helm_chart_version
  name             = var.helm_release_name
  namespace        = var.k8s_namespace
  create_namespace = var.k8s_create_namespace

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.k8s_service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cert_manager[0].arn
  }

  dynamic "set" {
    for_each = var.settings
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [var.mod_dependency]
}

resource "helm_release" "cert_manager_default_cluster_issuer" {
  count = var.enabled && var.cluster_issuer_enabled ? 1 : 0

  repository       = var.helm_repo_url
  chart            = var.helm_chart_name
  version          = var.helm_chart_version
  name             = var.helm_release_name
  namespace        = var.k8s_namespace
  create_namespace = var.k8s_create_namespace
  wait             = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = var.k8s_service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cert_manager[0].arn
  }

  set {
    name  = "ingressShim.defaultIssuerName"
    value = "default"
  }

  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }

  set {
    name  = "ingressShim.defaultIssuerGroup"
    value = "cert-manager.io"
  }

  dynamic "set" {
    for_each = var.settings
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [var.mod_dependency]
}

resource "time_sleep" "default_cluster_issuer" {
  count = var.enabled && var.cluster_issuer_enabled ? 1 : 0

  create_duration = "30s"

  depends_on = [
    helm_release.cert_manager_default_cluster_issuer
  ]
}

resource "helm_release" "default_cluster_issuer" {
  count = var.enabled && var.cluster_issuer_enabled ? 1 : 0

  chart     = "${path.module}/helm/defaultClusterIssuer"
  name      = "cert-manger-cluster-issuer"
  namespace = var.k8s_namespace

  dynamic "set" {
    for_each = var.cluster_issuer_settings
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [
    var.mod_dependency,
    time_sleep.default_cluster_issuer[0]
  ]
}
