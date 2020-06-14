# Base resources for ECS
resource aws_ecr_repository joneteus-spring-petclinic {
  name = var.app_name
}

resource aws_cloudwatch_log_group joneteus-spring-petclinic-logs {
  name = var.app_name
}

resource aws_ecs_cluster joneteus-spring-petclinic {
  name = var.app_name
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
  name = "${var.app_name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.joneteus-spring-petclinic-assume.json
}

# ECS Task Definition
data template_file joneteus-spring-petclinic-container-def {
  template = file("./spring-petclinic-container-def.json")
  vars = {
    app_name = var.app_name
    app_image = "${aws_ecr_repository.joneteus-spring-petclinic.repository_url}:latest"
    app_port = 8080
    fargate_cpu = 512
    fargate_memory = 1024
    aws_region = var.aws_region
  }
}

resource aws_ecs_task_definition joneteus-spring-petclinic {
  family = var.app_name
  requires_compatibilities = ["FARGATE"]
  cpu = 512
  memory = 1024
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.joneteus-spring-petclinic-ecs-task-exec.arn
  container_definitions = data.template_file.joneteus-spring-petclinic-container-def.rendered
}

# ECS Service
resource aws_security_group joneteus-spring-petclinic-ecs-sg {
  name_prefix        = "${var.app_name}-ecs"
  description = "Security group for ${var.app_name} ECS application"
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
  name = "${var.app_name}-service"
  cluster = aws_ecs_cluster.joneteus-spring-petclinic.id
  launch_type = "FARGATE"
  platform_version = "1.3.0"
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
    container_name   = var.app_name
    container_port   = 8080
  }

  depends_on = [aws_lb.joneteus-spring-petclinic-alb]
}

# Export values to SSM parameter store
resource aws_ssm_parameter joneteus-spring-petclinic-ecr-repo-name-param {
  type  = "String"
  overwrite = true
  name  = "/joneteus-spring-petclinic/ecr/repo-name"
  value = aws_ecr_repository.joneteus-spring-petclinic.name
}

resource aws_ssm_parameter joneteus-spring-petclinic-ecs-service-name-param {
  type  = "String"
  overwrite = true
  name  = "/joneteus-spring-petclinic/ecs/service-name"
  value = aws_ecs_service.joneteus-spring-petclinic.name
}

resource aws_ssm_parameter joneteus-spring-petclinic-ecs-cluster-name-param {
  type  = "String"
  overwrite = true
  name  = "/joneteus-spring-petclinic/ecs/cluster-name"
  value = aws_ecs_cluster.joneteus-spring-petclinic.name
}