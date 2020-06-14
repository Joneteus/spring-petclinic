aws_region = "eu-north-1"

app_name = "joneteus-spring-petclinic"
app_access_cidr = "88.148.236.57/32"

# Networks
# -> Public cidr block 10.50.0.0/17
# -> Private cidr block 10.50.128.0/17
vpc_cidr_block = "10.50.0.0/16"
subnet_public_cidrs = ["10.50.0.0/24", "10.50.1.0/24", "10.50.2.0/24"]
subnet_private_cidrs = ["10.50.128.0/24", "10.50.129.0/24", "10.50.130.0/24"]
