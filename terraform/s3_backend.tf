terraform {
  backend "s3" {
    region         = "eu-north-1"
    encrypt        = true
    bucket         = "joneteus-terraform-state-bucket"
    key            = "aws-spring-petclinic/state"
    dynamodb_table = "aws-spring-petclinic-lock"
  }
}