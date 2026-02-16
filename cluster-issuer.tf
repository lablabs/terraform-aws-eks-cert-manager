locals {
  cluster_issuer_enabled = var.enabled && var.cluster_issuer_enabled

  cluster_issuer_argo_source_type         = var.cluster_issuer_argo_source_type != null ? var.cluster_issuer_argo_source_type : try(local.cluster_issuer.argo_source_type, "helm-directory")
  cluster_issuer_argo_source_helm_enabled = local.cluster_issuer_argo_source_type == "helm-directory"

  cluster_issuer_argo_name         = var.cluster_issuer_argo_name != null ? var.cluster_issuer_argo_name : try(local.cluster_issuer.argo_name, local.cluster_issuer.name)
  cluster_issuer_helm_release_name = var.cluster_issuer_helm_release_name != null ? var.cluster_issuer_helm_release_name : try(local.cluster_issuer.helm_release_name, local.cluster_issuer.name)

  cluster_issuer_name = local.cluster_issuer_argo_source_helm_enabled ? local.cluster_issuer_helm_release_name : local.cluster_issuer_argo_name
}

module "cluster-issuer" {
  source = "git::https://github.com/lablabs/terraform-aws-eks-universal-addon.git//modules/addon?ref=v1.0.0-rc1"

  enabled = local.cluster_issuer_enabled

  # variable priority var.cluster_issuer_* (provided by the module user) > local.cluster_issuer.* (universal addon default override) > default (universal addon default)
  namespace = local.addon_namespace # cluster_issuer are cluster-wide resources, but for a Helm release we need a namespace to be the same as the addons itself

  helm_enabled                    = var.cluster_issuer_helm_enabled != null ? var.cluster_issuer_helm_enabled : lookup(local.cluster_issuer, "helm_enabled", null)
  helm_release_name               = local.cluster_issuer_name
  helm_chart_name                 = var.cluster_issuer_helm_chart_name != null ? var.cluster_issuer_helm_chart_name : lookup(local.cluster_issuer, "helm_chart_name", null)
  helm_chart_version              = var.cluster_issuer_helm_chart_version != null ? var.cluster_issuer_helm_chart_version : local.cluster_issuer.helm_chart_version
  helm_atomic                     = var.cluster_issuer_helm_atomic != null ? var.cluster_issuer_helm_atomic : lookup(local.cluster_issuer, "helm_atomic", null)
  helm_cleanup_on_fail            = var.cluster_issuer_helm_cleanup_on_fail != null ? var.cluster_issuer_helm_cleanup_on_fail : lookup(local.cluster_issuer, "helm_cleanup_on_fail", null)
  helm_create_namespace           = var.cluster_issuer_helm_create_namespace != null ? var.cluster_issuer_helm_create_namespace : lookup(local.cluster_issuer, "helm_create_namespace", null)
  helm_dependency_update          = var.cluster_issuer_helm_dependency_update != null ? var.cluster_issuer_helm_dependency_update : lookup(local.cluster_issuer, "helm_dependency_update", null)
  helm_description                = var.cluster_issuer_helm_description != null ? var.cluster_issuer_helm_description : lookup(local.cluster_issuer, "helm_description", null)
  helm_devel                      = var.cluster_issuer_helm_devel != null ? var.cluster_issuer_helm_devel : lookup(local.cluster_issuer, "helm_devel", null)
  helm_disable_openapi_validation = var.cluster_issuer_helm_disable_openapi_validation != null ? var.cluster_issuer_helm_disable_openapi_validation : lookup(local.cluster_issuer, "helm_disable_openapi_validation", null)
  helm_disable_webhooks           = var.cluster_issuer_helm_disable_webhooks != null ? var.cluster_issuer_helm_disable_webhooks : lookup(local.cluster_issuer, "helm_disable_webhooks", null)
  helm_force_update               = var.cluster_issuer_helm_force_update != null ? var.cluster_issuer_helm_force_update : lookup(local.cluster_issuer, "helm_force_update", null)
  helm_keyring                    = var.cluster_issuer_helm_keyring != null ? var.cluster_issuer_helm_keyring : lookup(local.cluster_issuer, "helm_keyring", null)
  helm_lint                       = var.cluster_issuer_helm_lint != null ? var.cluster_issuer_helm_lint : lookup(local.cluster_issuer, "helm_lint", null)
  helm_package_verify             = var.cluster_issuer_helm_package_verify != null ? var.cluster_issuer_helm_package_verify : lookup(local.cluster_issuer, "helm_package_verify", null)
  helm_postrender                 = var.cluster_issuer_helm_postrender != null ? var.cluster_issuer_helm_postrender : lookup(local.cluster_issuer, "helm_postrender", null)
  helm_recreate_pods              = var.cluster_issuer_helm_recreate_pods != null ? var.cluster_issuer_helm_recreate_pods : lookup(local.cluster_issuer, "helm_recreate_pods", null)
  helm_release_max_history        = var.cluster_issuer_helm_release_max_history != null ? var.cluster_issuer_helm_release_max_history : lookup(local.cluster_issuer, "helm_release_max_history", null)
  helm_render_subchart_notes      = var.cluster_issuer_helm_render_subchart_notes != null ? var.cluster_issuer_helm_render_subchart_notes : lookup(local.cluster_issuer, "helm_render_subchart_notes", null)
  helm_replace                    = var.cluster_issuer_helm_replace != null ? var.cluster_issuer_helm_replace : lookup(local.cluster_issuer, "helm_replace", null)
  helm_repo_ca_file               = var.cluster_issuer_helm_repo_ca_file != null ? var.cluster_issuer_helm_repo_ca_file : lookup(local.cluster_issuer, "helm_repo_ca_file", null)
  helm_repo_cert_file             = var.cluster_issuer_helm_repo_cert_file != null ? var.cluster_issuer_helm_repo_cert_file : lookup(local.cluster_issuer, "helm_repo_cert_file", null)
  helm_repo_key_file              = var.cluster_issuer_helm_repo_key_file != null ? var.cluster_issuer_helm_repo_key_file : lookup(local.cluster_issuer, "helm_repo_key_file", null)
  helm_repo_password              = var.cluster_issuer_helm_repo_password != null ? var.cluster_issuer_helm_repo_password : lookup(local.cluster_issuer, "helm_repo_password", null)
  helm_repo_url                   = var.cluster_issuer_helm_repo_url != null ? var.cluster_issuer_helm_repo_url : local.cluster_issuer.helm_repo_url
  helm_repo_username              = var.cluster_issuer_helm_repo_username != null ? var.cluster_issuer_helm_repo_username : lookup(local.cluster_issuer, "helm_repo_username", null)
  helm_reset_values               = var.cluster_issuer_helm_reset_values != null ? var.cluster_issuer_helm_reset_values : lookup(local.cluster_issuer, "helm_reset_values", null)
  helm_reuse_values               = var.cluster_issuer_helm_reuse_values != null ? var.cluster_issuer_helm_reuse_values : lookup(local.cluster_issuer, "helm_reuse_values", null)
  helm_set_sensitive              = var.cluster_issuer_helm_set_sensitive != null ? var.cluster_issuer_helm_set_sensitive : lookup(local.cluster_issuer, "helm_set_sensitive", null)
  helm_skip_crds                  = var.cluster_issuer_helm_skip_cluster_issuer != null ? var.cluster_issuer_helm_skip_cluster_issuer : lookup(local.cluster_issuer, "helm_skip_cluster_issuer", null)
  helm_timeout                    = var.cluster_issuer_helm_timeout != null ? var.cluster_issuer_helm_timeout : lookup(local.cluster_issuer, "helm_timeout", null)
  helm_wait                       = var.cluster_issuer_helm_wait != null ? var.cluster_issuer_helm_wait : lookup(local.cluster_issuer, "helm_wait", null)
  helm_wait_for_jobs              = var.cluster_issuer_helm_wait_for_jobs != null ? var.cluster_issuer_helm_wait_for_jobs : lookup(local.cluster_issuer, "helm_wait_for_jobs", null)

  argo_source_type            = local.cluster_issuer_argo_source_type
  argo_source_repo_url        = var.cluster_issuer_argo_source_repo_url != null ? var.cluster_issuer_argo_source_repo_url : lookup(local.cluster_issuer, "argo_source_repo_url", null)
  argo_source_target_revision = var.cluster_issuer_argo_source_target_revision != null ? var.cluster_issuer_argo_source_target_revision : lookup(local.cluster_issuer, "argo_source_target_revision", null)
  argo_source_path            = var.cluster_issuer_argo_source_path != null ? var.cluster_issuer_argo_source_path : lookup(local.cluster_issuer, "argo_source_path", null)

  argo_apiversion                                        = var.cluster_issuer_argo_apiversion != null ? var.cluster_issuer_argo_apiversion : lookup(local.cluster_issuer, "argo_apiversion", null)
  argo_destination_server                                = var.cluster_issuer_argo_destination_server != null ? var.cluster_issuer_argo_destination_server : lookup(local.cluster_issuer, "argo_destination_server", null)
  argo_enabled                                           = var.cluster_issuer_argo_enabled != null ? var.cluster_issuer_argo_enabled : lookup(local.cluster_issuer, "argo_enabled", null)
  argo_helm_enabled                                      = var.cluster_issuer_argo_helm_enabled != null ? var.cluster_issuer_argo_helm_enabled : lookup(local.cluster_issuer, "argo_helm_enabled", null)
  argo_helm_values                                       = var.cluster_issuer_argo_helm_values != null ? var.cluster_issuer_argo_helm_values : lookup(local.cluster_issuer, "argo_helm_values", null)
  argo_helm_wait_backoff_limit                           = var.cluster_issuer_argo_helm_wait_backoff_limit != null ? var.cluster_issuer_argo_helm_wait_backoff_limit : lookup(local.cluster_issuer, "argo_helm_wait_backoff_limit", null)
  argo_helm_wait_node_selector                           = var.cluster_issuer_argo_helm_wait_node_selector != null ? var.cluster_issuer_argo_helm_wait_node_selector : lookup(local.cluster_issuer, "argo_helm_wait_node_selector", null)
  argo_helm_wait_timeout                                 = var.cluster_issuer_argo_helm_wait_timeout != null ? var.cluster_issuer_argo_helm_wait_timeout : lookup(local.cluster_issuer, "argo_helm_wait_timeout", null)
  argo_helm_wait_tolerations                             = var.cluster_issuer_argo_helm_wait_tolerations != null ? var.cluster_issuer_argo_helm_wait_tolerations : lookup(local.cluster_issuer, "argo_helm_wait_tolerations", null)
  argo_helm_wait_kubectl_version                         = var.cluster_issuer_argo_helm_wait_kubectl_version != null ? var.cluster_issuer_argo_helm_wait_kubectl_version : lookup(local.cluster_issuer, "argo_helm_wait_kubectl_version", null)
  argo_info                                              = var.cluster_issuer_argo_info != null ? var.cluster_issuer_argo_info : lookup(local.cluster_issuer, "argo_info", null)
  argo_kubernetes_manifest_computed_fields               = var.cluster_issuer_argo_kubernetes_manifest_computed_fields != null ? var.cluster_issuer_argo_kubernetes_manifest_computed_fields : lookup(local.cluster_issuer, "argo_kubernetes_manifest_computed_fields", null)
  argo_kubernetes_manifest_field_manager_force_conflicts = var.cluster_issuer_argo_kubernetes_manifest_field_manager_force_conflicts != null ? var.cluster_issuer_argo_kubernetes_manifest_field_manager_force_conflicts : lookup(local.cluster_issuer, "argo_kubernetes_manifest_field_manager_force_conflicts", null)
  argo_kubernetes_manifest_field_manager_name            = var.cluster_issuer_argo_kubernetes_manifest_field_manager_name != null ? var.cluster_issuer_argo_kubernetes_manifest_field_manager_name : lookup(local.cluster_issuer, "argo_kubernetes_manifest_field_manager_name", null)
  argo_kubernetes_manifest_wait_fields                   = var.cluster_issuer_argo_kubernetes_manifest_wait_fields != null ? var.cluster_issuer_argo_kubernetes_manifest_wait_fields : lookup(local.cluster_issuer, "argo_kubernetes_manifest_wait_fields", null)
  argo_metadata                                          = var.cluster_issuer_argo_metadata != null ? var.cluster_issuer_argo_metadata : lookup(local.cluster_issuer, "argo_metadata", null)
  argo_name                                              = local.cluster_issuer_name
  argo_namespace                                         = var.cluster_issuer_argo_namespace != null ? var.cluster_issuer_argo_namespace : lookup(local.cluster_issuer, "argo_namespace", null)
  argo_project                                           = var.cluster_issuer_argo_project != null ? var.cluster_issuer_argo_project : lookup(local.cluster_issuer, "argo_project", null)
  argo_spec                                              = var.cluster_issuer_argo_spec != null ? var.cluster_issuer_argo_spec : lookup(local.cluster_issuer, "argo_spec", null)
  argo_spec_override                                     = var.cluster_issuer_argo_spec_override != null ? var.cluster_issuer_argo_spec_override : lookup(local.cluster_issuer, "argo_spec_override", null)
  argo_sync_policy                                       = var.cluster_issuer_argo_sync_policy != null ? var.cluster_issuer_argo_sync_policy : lookup(local.cluster_issuer, "argo_sync_policy", null)
  argo_operation                                         = var.cluster_issuer_argo_operation != null ? var.cluster_issuer_argo_operation : lookup(local.cluster_issuer, "argo_operation", null)

  settings = var.cluster_issuer_settings != null ? var.cluster_issuer_settings : lookup(local.cluster_issuer, "settings", null)
  values   = one(data.utils_deep_merge_yaml.cluster_issuer_values[*].output)

  depends_on = [
    local.cluster_issuer_depends_on,
    var.cluster_issuer_depends_on
  ]
}

data "utils_deep_merge_yaml" "cluster_issuer_values" {
  count = local.cluster_issuer_enabled ? 1 : 0

  input = compact([
    local.cluster_issuer_values,
    var.cluster_issuer_values
  ])
}

output "cluster_issuer" {
  description = "The cluster-issuer module outputs"
  value       = module.cluster-issuer
}
