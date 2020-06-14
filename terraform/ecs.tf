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
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
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
resource aws_security_group joneteus-spring-petclinic-ecs-sg {
  name_prefix        = "joneteus-spring-petclinic-ecs"
  description = "Security group for joneteus-spring-petclinic ECS application"
  vpc_id      = aws_vpc.joneteus-spring-petclinic-vpc.id

  ingress {
    description = "HTTP 8080 from ALB"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.joneteus-spring-petclinic-alb-sg.id]
  }
}

resource aws_ecs_service joneteus-spring-petclinic {
  name = "joneteus-spring-petclinic-service"
  cluster = aws_ecs_cluster.joneteus-spring-petclinic.id
  launch_type = "FARGATE"
  platform_version = "1.4.0"
  task_definition = aws_ecs_task_definition.joneteus-spring-petclinic.arn
  desired_count = 1

  network_configuration {
    security_groups = [ aws_security_group.joneteus-spring-petclinic-ecs-sg.id ]
    subnets = [
      aws_subnet.private-subnet-a.id,
      aws_subnet.private-subnet-b.id,
      aws_subnet.private-subnet-c.id
      ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.joneteus-spring-petclinic-tg.arn
    container_name   = "joneteus-spring-petclinic"
    container_port   = 8080
  }
}
