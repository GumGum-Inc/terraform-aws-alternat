generate "provider_aws" {
  path      = "provider_aws.tf"
  if_exists = "overwrite"
  contents  = <<EOF
  variable "provider_aws_region" {}
  variable "provider_aws_assume_role_arn" {}
  provider "aws" {
    region = var.provider_aws_region
    assume_role {
      role_arn = var.provider_aws_assume_role_arn
    }
    default_tags {
      tags = {
        billing    = "IT"
        owner      = "itsupport@gumgum.com"
        terraform  = true
        repository = "IT-Onboarding-Offboarding"
      }
    }
  }
  EOF
}