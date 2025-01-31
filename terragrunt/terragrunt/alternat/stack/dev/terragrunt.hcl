include "aws" {
  path   = find_in_parent_folders("aws.terragrunt.hcl")
  expose = true
}

include "account" {
  path = find_in_parent_folders("account.terragrunt.hcl")
  merge_strategy = "deep"
  expose = true
}

include "root" {
  path   = find_in_parent_folders("root.terragrunt.hcl")
  expose = true
}

terraform {
  source = "${get_terragrunt_dir()}/../../../../module"

  extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh",
      "destroy"
    ]
  }
}

inputs = {
  aws_region                    = "us-east-1"
  environment                   = "dev"
  lambda_role_name              = "jira_offboarding-lambda"
  lambda_ecr_repository         = "384127515584.dkr.ecr.us-east-1.amazonaws.com/gumgum-inc/it-onboarding-offboarding/jira_offboarding"
  lambda_policy_file            = file("../../files/lambda_policy.json")
  lambda_function_name          = "jira_offboarding"
  lambda_timeout                = 75
  lambda_memory_size            = 256
  lambda_size                   = 512
  apigateway_name               = "jira_offboarding-API"
  apigateway_integration_method = "POST"
  lambda_route                  = "/jira_offboarding"
  route53_zone_id               = "Z0124311O1HDBPV4BP8K"
  acm_certificate_arn           = "arn:aws:acm:us-east-1:384127515584:certificate/e3cc53c7-da64-40ca-9327-397f1d3a2a88"
  api_domain_name               = "jira-offboarding-dev.api.it.ggops.com"
}