variable aws_region {}


provider aws {
  version = "~> 2.0"
  region  = var.aws_region
}

# Networking
resource aws_default_vpc default {
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

resource aws_security_group joneteus-spring-petclinic-ecs {
  name        = "joneteus-spring-petclinic-ecs"
  description = "Security group for joneteus-spring-petclinic ECS application"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "HTTP 8080 from home"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["88.148.236.57/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# ECS Task Definition
resource aws_ecs_task_definition joneteus-spring-petclinic {
  family = "joneteus-spring-petclinic"
  requires_compatibilities = ["FARGATE"]
  cpu = 512
  memory = 1024
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.joneteus-spring-petclinic-ecs-task-exec.arn
  container_definitions = <<EOF
[
  {
    "name": "joneteus-spring-petclinic",
    "image": "${aws_ecr_repository.joneteus-spring-petclinic.repository_url}:latest",
    "essential": true,
    "cpu": 512,
    "memory": 1024,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.aws_region}",
        "awslogs-group": "joneteus-spring-petclinic",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOF
}

# ECS Service
resource aws_ecs_service joneteus-spring-petclinic {
  name = "joneteus-spring-petclinic-service"
  cluster = aws_ecs_cluster.joneteus-spring-petclinic.id
  task_definition = aws_ecs_task_definition.joneteus-spring-petclinic.arn
  launch_type = "FARGATE"
  desired_count = 1
  network_configuration {
    assign_public_ip = true
    security_groups = [ aws_security_group.joneteus-spring-petclinic-ecs.name ]
    subnets = [
      aws_default_subnet.subnet-a.id,
      aws_default_subnet.subnet-b.id,
      aws_default_subnet.subnet-c.id
      ]
  }
}
