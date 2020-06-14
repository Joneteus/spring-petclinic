provider aws {
  version = "~> 2.0"
  region  = var.aws_region
}

terraform {
  required_version = ">= 0.12"

  backend "s3" {
    region         = "eu-north-1"
    encrypt        = true
    bucket         = "joneteus-terraform-state-bucket"
    key            = "aws-spring-petclinic/state"
    dynamodb_table = "aws-spring-petclinic-lock"
  }
}