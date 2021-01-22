resource "aws_vpc" "vpc" {
  cidr_block       = var.base_cidr_block
  instance_tenancy = "default"

  tags = merge( #Inherit default tags and augment with resource specific tags.
    var.default_tags,
    {
        Name = "Terraform Coding Test"
    },
  )
}

resource "aws_subnet" "public_subnets" {
    for_each = var.public_subnets #Loop networks from public_subnets variable

    vpc_id            = aws_vpc.vpc.id
    availability_zone = each.key #Use map key to get AZ name
    cidr_block        = each.value #Use map value for /24 CIDR

    tags = merge( #Inherit default tags and augment with resource specific tags.
        var.default_tags,
        {
            Name = "Terraform Coding Test Public - ${each.key}"
        },
    )
}

resource "aws_subnet" "private_subnets" {
    for_each = var.private_subnets #Loop networks from private_subnets variable

    vpc_id            = aws_vpc.vpc.id
    availability_zone = each.key #Use map key to get AZ name
    cidr_block        = each.value #Use map value for /24 CIDR

    tags = merge( #Inherit default tags and augment with resource specific tags.
        var.default_tags,
        {
            Name = "Terraform Coding Test Private - ${each.key}"
        },
    )
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = merge( #Inherit default tags and augment with resource specific tags.
        var.default_tags,
        {
            Name = "Terraform Coding Test"
        },
    )
}

resource "aws_eip" "natgw" { #Public IPv4 for NAT Gateway
  vpc      = true
  tags = merge( #Inherit default tags and augment with resource specific tags.
    var.default_tags,
        {
            Name = "Terraform Coding Test Nat GW"
        },
    )
}

resource "aws_nat_gateway" "natgw" { #NAT Gateway for instance internet access, not resilent, used for docker pull only.
  allocation_id = aws_eip.natgw.id
  subnet_id     = aws_subnet.public_subnets["eu-west-2a"].id

  tags = merge( #Inherit default tags and augment with resource specific tags.
    var.default_tags,
        {
            Name = "Terraform Coding Test"
        },
    )
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge( #Inherit default tags and augment with resource specific tags.
    var.default_tags,
        {
            Name = "Terraform Coding Test Public"
        },
    )
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw.id
    }
    
    tags = merge( #Inherit default tags and augment with resource specific tags.
    var.default_tags,
        {
            Name = "Terraform Coding Test Private"
        },
    )
}

resource "aws_route_table_association" "public_assoc" {
    count = length(aws_subnet.public_subnets)
    subnet_id      = [for subnet in aws_subnet.public_subnets : subnet.id][count.index]
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_assoc" {
    count = length(aws_subnet.private_subnets)
    subnet_id      = [for subnet in aws_subnet.private_subnets : subnet.id][count.index]
    route_table_id = aws_route_table.private_route_table.id
}