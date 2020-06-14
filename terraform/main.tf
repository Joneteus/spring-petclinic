variable aws_region {}
variable vpc_cidr_block {}
variable subnet_public_cidrs {}
variable subnet_private_cidrs {}


provider aws {
  version = "~> 2.0"
  region  = var.aws_region
}

# Networking

resource aws_vpc joneteus-spring-petclinic-vpc {
  cidr_block       = var.vpc_cidr_block
  enable_dns_hostnames = true
}

## Public subnets
resource aws_internet_gateway joneteus-spring-petclinic-igw {
  vpc_id = aws_vpc.joneteus-spring-petclinic-vpc.id
}

resource aws_eip public-subnet-a-nat-eip {
  vpc = true
}

resource aws_nat_gateway public-subnet-a-ngw {
  allocation_id = aws_eip.public-subnet-a-nat-eip.id
  subnet_id     = aws_subnet.public-subnet-a.id
}

resource aws_route_table joneteus-spring-petclinic-public-rt {
  vpc_id = aws_vpc.joneteus-spring-petclinic-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.joneteus-spring-petclinic-igw.id
  }
}

resource aws_subnet public-subnet-a {
  vpc_id = aws_vpc.joneteus-spring-petclinic-vpc.id
  cidr_block = var.subnet_public_cidrs[0]
  availability_zone = join("", [var.aws_region, "a"])
  map_public_ip_on_launch = true
}

resource aws_route_table_association public-subnet-a-rta {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.joneteus-spring-petclinic-public-rt.id
}

resource aws_subnet public-subnet-b {
  vpc_id = aws_vpc.joneteus-spring-petclinic-vpc.id
  cidr_block = var.subnet_public_cidrs[1]
  availability_zone = join("", [var.aws_region, "b"])
  map_public_ip_on_launch = true
}

resource aws_route_table_association public-subnet-b-rta {
  subnet_id      = aws_subnet.public-subnet-b.id
  route_table_id = aws_route_table.joneteus-spring-petclinic-public-rt.id
}

resource aws_subnet public-subnet-c {
  vpc_id = aws_vpc.joneteus-spring-petclinic-vpc.id
  cidr_block = var.subnet_public_cidrs[2]
  availability_zone = join("", [var.aws_region, "c"])
  map_public_ip_on_launch = true
}

resource aws_route_table_association public-subnet-c-rta {
  subnet_id      = aws_subnet.public-subnet-c.id
  route_table_id = aws_route_table.joneteus-spring-petclinic-public-rt.id
}

## Private subnets
resource aws_route_table joneteus-spring-petclinic-private-rt {
  vpc_id = aws_vpc.joneteus-spring-petclinic-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public-subnet-a-ngw.id
  }
}

resource aws_subnet private-subnet-a {
  vpc_id = aws_vpc.joneteus-spring-petclinic-vpc.id
  cidr_block = var.subnet_private_cidrs[0]
  availability_zone = join("", [var.aws_region, "a"])
}

resource aws_route_table_association private-subnet-a-rta {
  subnet_id      = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.joneteus-spring-petclinic-private-rt.id
}

resource aws_subnet private-subnet-b {
  vpc_id = aws_vpc.joneteus-spring-petclinic-vpc.id
  cidr_block = var.subnet_private_cidrs[1]
  availability_zone = join("", [var.aws_region, "b"])
}

resource aws_route_table_association private-subnet-b-rta {
  subnet_id      = aws_subnet.private-subnet-b.id
  route_table_id = aws_route_table.joneteus-spring-petclinic-private-rt.id
}

resource aws_subnet private-subnet-c {
  vpc_id = aws_vpc.joneteus-spring-petclinic-vpc.id
  cidr_block = var.subnet_private_cidrs[2]
  availability_zone = join("", [var.aws_region, "c"])
}

resource aws_route_table_association private-subnet-c-rta {
  subnet_id      = aws_subnet.private-subnet-c.id
  route_table_id = aws_route_table.joneteus-spring-petclinic-private-rt.id
}

# Load Balancing
resource aws_security_group joneteus-spring-petclinic-alb-sg {
  name_prefix = "joneteus-spring-petclinic-alb"
  description = "Security group for joneteus-spring-petclinic Application Load Balancer"
  vpc_id      = aws_vpc.joneteus-spring-petclinic-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["88.148.236.57/32"]
  }
}

resource aws_lb joneteus-spring-petclinic-alb {
  name               = "joneteus-spring-petclinic-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.joneteus-spring-petclinic-alb-sg.id]
  subnets            = [
    aws_subnet.public-subnet-a.id, 
    aws_subnet.public-subnet-b.id, 
    aws_subnet.public-subnet-c.id
  ]
}

resource aws_lb_listener joneteus-spring-petclinic-http  {
  load_balancer_arn = aws_lb.joneteus-spring-petclinic-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.joneteus-spring-petclinic-tg.arn}"
  }
}

resource aws_lb_target_group joneteus-spring-petclinic-tg {
  name     = "joneteus-spring-petclinic-alb-tg"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.joneteus-spring-petclinic-vpc.id
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
