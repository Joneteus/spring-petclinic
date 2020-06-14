variable aws_region {}


provider aws {
  version = "~> 2.0"
  region  = var.aws_region
}

resource aws_default_subnet subnet-a {
  availability_zone = join("", [var.aws_region, "a"])
}

resource aws_default_subnet subnet-b {
  availability_zone = join("", [var.aws_region, "b"])
}

resource aws_default_subnet subnet-c {
  availability_zone = join("", [var.aws_region, "c"])
}

resource aws_ecr_repository joneteus-spring-petclinic {
  name = "joneteus-spring-petclinic"
}

resource aws_cloudwatch_log_group joneteus-spring-petclinic-logs {
  name = "joneteus-spring-petclinic"
}

resource aws_ecs_cluster joneteus-spring-petclinic {
  name = "joneteus-spring-petclinic"
}
