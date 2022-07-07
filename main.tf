# create optional domain kms encryption key
locals {
  kms_key_description = (
    var.codeartifact_domain_kms_key_description == "" ?
    "domain kms key for ${var.codeartifact_domain_name} domain" :
    var.codeartifact_domain_kms_key_description
  )
}

resource "aws_kms_key" "codeartifact_domain" {
  count       = var.enable_codeartifact_domain_kms_key ? 1 : 0
  description = local.kms_key_description
  tags        = var.tags
}

# create codeartifact domain
locals {
  encryption_key_arn = (
    var.enable_codeartifact_domain_kms_key ?
    one(aws_kms_key.codeartifact_domain[*].arn) :
    var.codeartifact_domain_kms_key_arn
  )
}

resource "aws_codeartifact_domain" "domain" {
  count          = var.enable_codeartifact_domain ? 1 : 0
  domain         = var.codeartifact_domain_name
  encryption_key = local.encryption_key_arn
  tags           = var.tags
}

# create repositories
locals {
  domain = (
    var.enable_codeartifact_domain ?
    one(aws_codeartifact_domain.domain[*].domain) :
    var.codeartifact_domain_name
  )
}

resource "aws_codeartifact_repository" "repository" {
  count       = length(var.codeartifact_repositories)
  repository  = var.codeartifact_repositories[count.index].name
  description = var.codeartifact_repositories[count.index].description
  domain      = local.domain
  tags        = var.tags

  dynamic "external_connections" {
    for_each = var.codeartifact_repositories[count.index].external_connections

    content {
      external_connection_name = external_connections.value.external_connection_name
    }
  }
}

# CICD role with access to codeartifact and ecr
data "aws_iam_policy_document" "cicd_codeartifact" {
  count = var.enable_cicd_role ? 1 : 0

  statement {
    actions = [
      "codeartifact:GetAuthorizationToken",
      "codeartifact:GetRepositoryEndpoint",
      "codeartifact:PublishPackageVersion",
      "codeartifact:ReadFromRepository",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cicd_codeartifact_sts" {
  count = var.enable_cicd_role ? 1 : 0

  statement {
    actions = [
      "sts:GetServiceBearerToken",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "sts:AWSServiceName"
      values = [
        "codeartifact.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "cicd_ecr" {
  count = var.enable_cicd_role ? 1 : 0

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:SetRepositoryPolicy",
      "ecr:UploadLayerPart",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "cicd_assume_role_policy" {
  count = var.enable_cicd_role ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      type        = "AWS"
      identifiers = var.cicd_role_trust_arns
    }
  }
}

resource "aws_iam_role" "cicd_role" {
  count = var.enable_cicd_role ? 1 : 0

  name               = var.cicd_role_name
  description        = var.cicd_role_description
  assume_role_policy = data.aws_iam_policy_document.cicd_assume_role_policy[count.index].json
  tags               = var.tags

  inline_policy {
    name   = "cicd-code-artifact"
    policy = data.aws_iam_policy_document.cicd_codeartifact[count.index].json
  }

  inline_policy {
    name   = "cicd-code-artifact-sts"
    policy = data.aws_iam_policy_document.cicd_codeartifact_sts[count.index].json
  }

  inline_policy {
    name   = "cicd-ecr"
    policy = data.aws_iam_policy_document.cicd_ecr[count.index].json
  }
}
