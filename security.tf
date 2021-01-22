resource "aws_security_group" "loadbancer_ingress" { #Security group for ingress loadbalancer
  name        = "loadbancer_ingress"
  description = "Allow port 80 (HTTP) in from anywhere"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = merge( #Inherit default tags and augment with resource specific tags.
    var.default_tags,
        {
            Name = "Loadbalancer Ingress"
        },
    )
}

resource "aws_security_group" "instance_ingress" { #Security group for instances
  name        = "instance_ingress"
  description = "Allow port 80 (HTTP) in from loadbalancer security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP from loadbalancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.loadbancer_ingress.id] #Allow HTTP connection only from the loadbalancer security group.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = merge( #Inherit default tags and augment with resource specific tags.
    var.default_tags,
        {
            Name = "Instance Ingress"
        },
    )
}