variable aws_region {}


provider aws {
  version = "~> 2.0"
  region  = var.aws_region
}

# Networking
resource aws_default_subnet subnet-a {
  availability_zone = join("", [var.aws_region, "a"])
}

resource aws_default_subnet subnet-b {
  availability_zone = join("", [var.aws_region, "b"])
}

resource aws_default_subnet subnet-c {
  availability_zone = join("", [var.aws_region, "c"])
}

# Base resources for ECS
resource aws_ecr_repository joneteus-spring-petclinic {
  name = "joneteus-spring-petclinic"
}

resource aws_cloudwatch_log_group joneteus-spring-petclinic-logs {
  name = "joneteus-spring-petclinic"
}

resource aws_ecs_cluster joneteus-spring-petclinic {
  name = "joneteus-spring-petclinic"
}

# ECS Task execution role
data aws_iam_policy_document joneteus-spring-petclinic-assume {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource aws_iam_role_policy_attachment aws-ecs-task-exec-attach {
  role       = aws_iam_role.joneteus-spring-petclinic-ecs-task-exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource aws_iam_role joneteus-spring-petclinic-ecs-task-exec {
  name = "joneteus-spring-petclinic-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.joneteus-spring-petclinic-assume.json
}
