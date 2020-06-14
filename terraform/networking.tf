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