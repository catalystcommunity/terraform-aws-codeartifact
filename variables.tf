variable "enable_codeartifact_domain_kms_key" {
  description = "Whether to enable creation of a KMS key for the CodeArtifact domain"
  type        = bool
  default     = false
}

variable "codeartifact_domain_kms_key_description" {
  description = "Description of KMS key to create if enabled"
  type        = string
  default     = ""
}

variable "enable_codeartifact_domain" {
  description = "Whether to enable creation of a CodeArtifact domain"
  type        = bool
  default     = true
}

variable "codeartifact_domain_name" {
  description = "Name of CodeArtifact domain to create or reference based on var.enable_codeartifact_domain"
  type        = string
}

variable "codeartifact_domain_kms_key_arn" {
  description = "CodeArtifact domain KMS key to use if var.enable_codeartifact_domain_kms_key is disabled"
  type        = string
  default     = null
}

variable "codeartifact_repositories" {
  description = "List of repositories to create. Defaults to NPM with public NPM external connection"
  type = list(object({
    name        = string
    description = string
    external_connections = list(object({
      external_connection_name = string
    }))
    upstreams = optional(list(object({
      upstream_repository_name = string
    })))
  }))
  default = [
    {
      name        = "npm"
      description = "NPM repository"
      external_connections = [{
        external_connection_name = "public:npmjs"
      }]
    }
  ]
}

variable "enable_cicd_role" {
  description = "Enables creation of a CICD role which grants access to Code Artifact and ECR"
  type        = bool
  default     = false
}

variable "cicd_role_trust_arns" {
  description = "ARNs to trust for assume role"
  type        = list(string)
  default     = []
}

variable "cicd_role_name" {
  description = "Name of the CICD role to create"
  type        = string
  default     = "cicd"
}

variable "cicd_role_description" {
  description = "Description of the CICD role to create"
  type        = string
  default     = "Role assumed by CICD pipelines"
}

variable "tags" {
  type    = map(string)
  default = {}
}
