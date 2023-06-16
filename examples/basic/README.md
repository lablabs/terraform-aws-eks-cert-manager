# Basic example

The code in this example shows how to use the module with basic configuration and minimal set of other resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.19.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.11.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cert_manager_argo_helm"></a> [cert\_manager\_argo\_helm](#module\_cert\_manager\_argo\_helm) | ../../ | n/a |
| <a name="module_cert_manager_argo_kubernetes"></a> [cert\_manager\_argo\_kubernetes](#module\_cert\_manager\_argo\_kubernetes) | ../../ | n/a |
| <a name="module_cert_manager_assume"></a> [cert\_manager\_assume](#module\_cert\_manager\_assume) | ../../ | n/a |
| <a name="module_cert_manager_disabled"></a> [cert\_manager\_disabled](#module\_cert\_manager\_disabled) | ../../ | n/a |
| <a name="module_cert_manager_helm"></a> [cert\_manager\_helm](#module\_cert\_manager\_helm) | ../../ | n/a |
| <a name="module_cert_manager_without_irsa_policy"></a> [cert\_manager\_without\_irsa\_policy](#module\_cert\_manager\_without\_irsa\_policy) | ../../ | n/a |
| <a name="module_cert_manager_without_irsa_role"></a> [cert\_manager\_without\_irsa\_role](#module\_cert\_manager\_without\_irsa\_role) | ../../ | n/a |
| <a name="module_eks_cluster"></a> [eks\_cluster](#module\_eks\_cluster) | cloudposse/eks-cluster/aws | 2.3.0 |
| <a name="module_eks_node_group"></a> [eks\_node\_group](#module\_eks\_node\_group) | cloudposse/eks-node-group/aws | 2.4.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 4.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
