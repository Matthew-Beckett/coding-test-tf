resource "aws_lb" "instance_ingress" { #Main ingress loadbalancer
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.loadbancer_ingress.id]
    subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]

    enable_deletion_protection = false #This will break tf destroy if you turn it on!

    tags = merge( #Inherit default tags and augment with resource specific tags.
    var.default_tags,
        {
            Name = "Terraform Coding Test Ingress"
        },
    )
}

resource "aws_lb_target_group" "instances" { #Target group for ASG instances
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.vpc.id
    tags = merge( #Inherit default tags and augment with resource specific tags.
    var.default_tags,
        {
            Name = "Terraform Coding Test Instances"
        },
    )
}

resource "aws_lb_listener" "instance_ingress_listener_http" { #ALB listener on port 80 (HTTP)
  load_balancer_arn = aws_lb.instance_ingress.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instances.arn
  }
}