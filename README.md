# terraform-aws-codeartifact

The terraform-aws-codeartifact module optionally creates all resources
necessary for creating an AWS CodeArtifact repository, including creating a
domain and KMS key for encryption.

Additionally, this module can provision a role for use by CICD systems to
upload to CodeArtifact. It includes upload access to ECR as well, as these
systems are often used together.

By default, the module will create an NPM repository with the public NPM
repository as an external connection.


## Example Implementations

### Basic

The most basic implementation creates all necessary resources for managing an
NPM repository.
```terraform
module "codeartifact" {
  source = "github.com/catalystsquad/terraform-aws-codeartifact"

  enable_codeartifact_domain_kms_key = true
  codeartifact_domain_name           = "mydomain"
}
```

### CICD Role

```terraform
module "codeartifact" {
  source = "github.com/catalystsquad/terraform-aws-codeartifact"

  enable_codeartifact_domain_kms_key = true
  codeartifact_domain_name           = "mydomain"
  enable_cicd_role                   = true
  cicd_role_trust_arns               = ["arn:aws:iam::123456789999:user/my-cicd-user"]
}

```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codeartifact_domain_name"></a> [codeartifact\_domain\_name](#input\_codeartifact\_domain\_name) | Name of CodeArtifact domain to create or reference based on var.enable\_codeartifact\_domain | `string` | n/a | yes |
| <a name="input_cicd_role_description"></a> [cicd\_role\_description](#input\_cicd\_role\_description) | Description of the CICD role to create | `string` | `"Role assumed by CICD pipelines"` | no |
| <a name="input_cicd_role_name"></a> [cicd\_role\_name](#input\_cicd\_role\_name) | Name of the CICD role to create | `string` | `"cicd"` | no |
| <a name="input_cicd_role_trust_arns"></a> [cicd\_role\_trust\_arns](#input\_cicd\_role\_trust\_arns) | ARNs to trust for assume role | `list(string)` | `[]` | no |
| <a name="input_codeartifact_domain_kms_key_arn"></a> [codeartifact\_domain\_kms\_key\_arn](#input\_codeartifact\_domain\_kms\_key\_arn) | CodeArtifact domain KMS key to use if var.enable\_codeartifact\_domain\_kms\_key is disabled | `string` | `null` | no |
| <a name="input_codeartifact_domain_kms_key_description"></a> [codeartifact\_domain\_kms\_key\_description](#input\_codeartifact\_domain\_kms\_key\_description) | Description of KMS key to create if enabled | `string` | `""` | no |
| <a name="input_codeartifact_repositories"></a> [codeartifact\_repositories](#input\_codeartifact\_repositories) | List of repositories to create. Defaults to NPM with public NPM external connection | <pre>list(object({<br>    name        = string<br>    description = string<br>    external_connections = list(object({<br>      external_connection_name = string<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "description": "NPM repository",<br>    "external_connections": [<br>      {<br>        "external_connection_name": "public:npmjs"<br>      }<br>    ],<br>    "name": "npm"<br>  }<br>]</pre> | no |
| <a name="input_enable_cicd_role"></a> [enable\_cicd\_role](#input\_enable\_cicd\_role) | Enables creation of a CICD role which grants access to Code Artifact and ECR | `bool` | `false` | no |
| <a name="input_enable_codeartifact_domain"></a> [enable\_codeartifact\_domain](#input\_enable\_codeartifact\_domain) | Whether to enable creation of a CodeArtifact domain | `bool` | `true` | no |
| <a name="input_enable_codeartifact_domain_kms_key"></a> [enable\_codeartifact\_domain\_kms\_key](#input\_enable\_codeartifact\_domain\_kms\_key) | Whether to enable creation of a KMS key for the CodeArtifact domain | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

No outputs.

## Resources

| Name | Type |
|------|------|
| [aws_codeartifact_domain.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_domain) | resource |
| [aws_codeartifact_repository.repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_repository) | resource |
| [aws_iam_role.cicd_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kms_key.codeartifact_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_iam_policy_document.cicd_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cicd_codeartifact](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cicd_codeartifact_sts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cicd_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->
