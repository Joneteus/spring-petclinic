variable aws_region {
    type = string
}

variable app_name {
    type = string
}

variable app_access_cidr {
    type = string
}

variable vpc_cidr_block {
    type = string
}

variable subnet_public_cidrs {
    type = list(string)
}

variable subnet_private_cidrs {
    type = list(string)
}