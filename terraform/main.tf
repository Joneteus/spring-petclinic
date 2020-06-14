variable aws_region {}
variable vpc_cidr_block {}
variable subnet_public_cidrs {}
variable subnet_private_cidrs {}


provider aws {
  version = "~> 2.0"
  region  = var.aws_region
}

# Networking

## Generic VPC stuff
resource aws_vpc joneteus-spring-petclinic-vpc {
  cidr_block       = var.vpc_cidr_block
  enable_dns_hostnames = true
}

resource aws_internet_gateway joneteus-spring-petclinic-igw {
  vpc_id = aws_vpc.joneteus-spring-petclinic-vpc.id
}

## Public subnets
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

resource aws_route_table_association public-subnet-a-rt-ass {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.joneteus-spring-petclinic-public-rt.id
}

resource aws_subnet public-subnet-b {
  vpc_id = aws_vpc.joneteus-spring-petclinic-vpc.id
  cidr_block = var.subnet_public_cidrs[1]
  availability_zone = join("", [var.aws_region, "a"])
  map_public_ip_on_launch = true
}

resource aws_route_table_association public-subnet-b-rt-ass {
  subnet_id      = aws_subnet.public-subnet-b.id
  route_table_id = aws_route_table.joneteus-spring-petclinic-public-rt.id
}

resource aws_subnet public-subnet-c {
  vpc_id = aws_vpc.joneteus-spring-petclinic-vpc.id
  cidr_block = var.subnet_public_cidrs[2]
  availability_zone = join("", [var.aws_region, "a"])
  map_public_ip_on_launch = true
}

resource aws_route_table_association public-subnet-c-rt-ass {
  subnet_id      = aws_subnet.public-subnet-c.id
  route_table_id = aws_route_table.joneteus-spring-petclinic-public-rt.id
}

resource aws_security_group joneteus-spring-petclinic-ecs {
  name        = "joneteus-spring-petclinic-ecs"
  description = "Security group for joneteus-spring-petclinic ECS application"
  vpc_id      = aws_vpc.joneteus-spring-petclinic-vpc.id

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
    security_groups = [ aws_security_group.joneteus-spring-petclinic-ecs.id ]
    subnets = [
      aws_subnet.public-subnet-a.id,
      aws_subnet.public-subnet-b.id,
      aws_subnet.public-subnet-c.id
      ]
  }
}
