variable "default_tags" {
  default = {
      "Project" = "tf-coding-test"
      "State Managament" = "terraform"
  }
  description = "Default tags for all resources"
  type = map(string)
}

variable "base_cidr_block" {
    default = "10.0.0.0/16"
    type = string
}

variable "private_subnets" {
    default = {
        "eu-west-2a" = "10.0.1.0/24",
        "eu-west-2b" = "10.0.2.0/24",
        "eu-west-2c" = "10.0.3.0/24"
    }
    description = "A map of availability zone and CIDR blocks to create"
}

variable "public_subnets" {
    default = {
        "eu-west-2a" = "10.0.4.0/24",
        "eu-west-2b" = "10.0.5.0/24",
        "eu-west-2c" = "10.0.6.0/24"
    }
    description = "A map of availability zone and CIDR blocks to create"
}

variable "minimum_instance_count" {
    default = 3
    description = "The minimum amount of instances available in the auto-scaling group"
}

variable "maximum_instance_count" {
    default = 3
    description = "The maximum amount of instances available in the auto-scaling group"
}