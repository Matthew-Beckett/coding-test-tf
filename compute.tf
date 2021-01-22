resource "aws_placement_group" "instance" { #Create placement group with highly available strategy
    name     = "instance"
    strategy = "spread" #Set placement strategy to spread for highest resiliency
    tags = merge( #Inherit default tags and augment with resource specific tags.
        var.default_tags,
        {
            Name = "Terraform Coding Test"
        },
    )
}

resource "aws_launch_template" "instance" { #Define launch template with parameters for instance creation
  name_prefix = "instance-"
  vpc_security_group_ids = [aws_security_group.instance_ingress.id]
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 30 #Attach additional 30G block storage device
    }
  }
  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }
  credit_specification {
    cpu_credits = "standard"
  }
  ebs_optimized = true
  image_id = "ami-0e80a462ede03e653"
  instance_initiated_shutdown_behavior = "terminate" #Make all instances ephemeral
  instance_type = "t3.small" #Was t3.micro but it was sloooowwww

  lifecycle {
    create_before_destroy = true #Lifcycle policy ensures that a new ASG is created before the old is destroyed
  }                              # during tf destroy or where a replacment operation is needed. Eliminates downtime

  tag_specifications {
    resource_type = "instance" #Propagate tags to instances
    tags = merge( #Inherit default tags and augment with resource specific tags.
        var.default_tags,
        {
            Name = "Terraform Coding Test"
        },
    )
  }

  user_data = filebase64("${path.module}/deploy.sh") #Pushes deploy.sh script via user-data field for example
}                                                    # application deployment

resource "aws_autoscaling_group" "instances" { #Scaling group definition
    name = "tf-instance-${aws_launch_template.instance.latest_version}-asg" #Making the name depenent on the version
    capacity_rebalance  = true                                              # of the launch template forces a replacement
    desired_capacity    = var.minimum_instance_count                        # when the template changes
    max_size            = var.maximum_instance_count
    min_size            = 0
    vpc_zone_identifier = [for subnet in aws_subnet.private_subnets : subnet.id]
    placement_group = aws_placement_group.instance.id #Make sure the placement group is applied for good AZ distirbution
    target_group_arns = [aws_lb_target_group.instances.arn] #Make ASG handle target group attachment
    launch_template {
        id      = aws_launch_template.instance.id
        version = aws_launch_template.instance.latest_version
    }
    lifecycle {
        create_before_destroy = true #Same as above, just extra protection to ensure limited downtime in replacement
    }                                #scenario
}