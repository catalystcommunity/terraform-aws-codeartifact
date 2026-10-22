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
  source = "github.com/catalystcommunity/terraform-aws-codeartifact"

  enable_codeartifact_domain_kms_key = true
  codeartifact_domain_name           = "mydomain"
}
```

### CICD Role

```terraform
module "codeartifact" {
  source = "github.com/catalystcommunity/terraform-aws-codeartifact"

  enable_codeartifact_domain_kms_key = true
  codeartifact_domain_name           = "mydomain"
  enable_cicd_role                   = true
  cicd_role_trust_arns               = ["arn:aws:iam::123456789999:user/my-cicd-user"]
}

```

### Cross-account domain access

Set `enable_codeartifact_domain_permissions_policy` to `true` and provide the
domain permissions policy as a JSON string. This example lets a role in another
account request a CodeArtifact authorization token for the domain:

```terraform
module "codeartifact" {
  source = "github.com/catalystcommunity/terraform-aws-codeartifact"

  codeartifact_domain_name                      = "mydomain"
  enable_codeartifact_domain_permissions_policy = true
  codeartifact_domain_permissions_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::123456789012:role/codeartifact-consumer"
      }
      Action   = ["codeartifact:GetAuthorizationToken"]
      Resource = "*"
    }]
  })
}
```

To read packages, the role also needs a repository permissions policy
(`aws_codeartifact_repository_permissions_policy`) on each repository. This
module does not create repository permissions policies.

The role's identity policy must also allow the CodeArtifact actions it uses,
including `sts:GetServiceBearerToken` for `codeartifact.amazonaws.com`. A
domain permissions policy cannot grant `sts:GetServiceBearerToken`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codeartifact_domain_name"></a> [codeartifact\_domain\_name](#input\_codeartifact\_domain\_name) | Name of CodeArtifact domain to create or reference based on var.enable\_codeartifact\_domain | `string` | n/a | yes |
| <a name="input_cicd_role_description"></a> [cicd\_role\_description](#input\_cicd\_role\_description) | Description of the CICD role to create | `string` | `"Role assumed by CICD pipelines"` | no |
| <a name="input_cicd_role_name"></a> [cicd\_role\_name](#input\_cicd\_role\_name) | Name of the CICD role to create | `string` | `"cicd"` | no |
| <a name="input_cicd_role_trust_arns"></a> [cicd\_role\_trust\_arns](#input\_cicd\_role\_trust\_arns) | ARNs to trust for assume role | `list(string)` | `[]` | no |
| <a name="input_codeartifact_domain_kms_key_arn"></a> [codeartifact\_domain\_kms\_key\_arn](#input\_codeartifact\_domain\_kms\_key\_arn) | CodeArtifact domain KMS key to use if var.enable\_codeartifact\_domain\_kms\_key is disabled | `string` | `null` | no |
| <a name="input_codeartifact_domain_kms_key_description"></a> [codeartifact\_domain\_kms\_key\_description](#input\_codeartifact\_domain\_kms\_key\_description) | Description of KMS key to create if enabled | `string` | `""` | no |
| <a name="input_codeartifact_domain_owner"></a> [codeartifact\_domain\_owner](#input\_codeartifact\_domain\_owner) | Account ID that owns the CodeArtifact domain. Defaults to the current account | `string` | `null` | no |
| <a name="input_codeartifact_domain_permissions_policy"></a> [codeartifact\_domain\_permissions\_policy](#input\_codeartifact\_domain\_permissions\_policy) | JSON policy document to apply to the CodeArtifact domain if var.enable\_codeartifact\_domain\_permissions\_policy is enabled | `string` | `null` | no |
| <a name="input_codeartifact_repositories"></a> [codeartifact\_repositories](#input\_codeartifact\_repositories) | List of repositories to create. Defaults to NPM with public NPM external connection | <pre>list(object({<br>    name        = string<br>    description = string<br>    external_connections = list(object({<br>      external_connection_name = string<br>    }))<br>    upstreams = optional(list(object({<br>      upstream_repository_name = string<br>    })))<br>  }))</pre> | <pre>[<br>  {<br>    "description": "NPM repository",<br>    "external_connections": [<br>      {<br>        "external_connection_name": "public:npmjs"<br>      }<br>    ],<br>    "name": "npm"<br>  }<br>]</pre> | no |
| <a name="input_enable_cicd_role"></a> [enable\_cicd\_role](#input\_enable\_cicd\_role) | Enables creation of a CICD role which grants access to Code Artifact and ECR | `bool` | `false` | no |
| <a name="input_enable_codeartifact_domain"></a> [enable\_codeartifact\_domain](#input\_enable\_codeartifact\_domain) | Whether to enable creation of a CodeArtifact domain | `bool` | `true` | no |
| <a name="input_enable_codeartifact_domain_kms_key"></a> [enable\_codeartifact\_domain\_kms\_key](#input\_enable\_codeartifact\_domain\_kms\_key) | Whether to enable creation of a KMS key for the CodeArtifact domain | `bool` | `false` | no |
| <a name="input_enable_codeartifact_domain_permissions_policy"></a> [enable\_codeartifact\_domain\_permissions\_policy](#input\_enable\_codeartifact\_domain\_permissions\_policy) | Whether to manage a permissions policy on the CodeArtifact domain. Changing this from true to false deletes the policy | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

No outputs.

## Resources

| Name | Type |
|------|------|
| [aws_codeartifact_domain.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_domain) | resource |
| [aws_codeartifact_domain_permissions_policy.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_domain_permissions_policy) | resource |
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
