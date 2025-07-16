variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "subnets" {
  description = "subnets"
  type = list(object({
    name                    = string
    cidr_block              = string
    availability_zone       = string
  }))
}

variable "map_public_ip_on_launch" {
  description = "map public ip on launch"
  type        = bool
}

resource "aws_subnet" "this" {
  for_each = { for i in var.subnets : i.name => i }

  vpc_id = var.vpc_id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    "Name" = each.value.name
  }
}

output "ids" {
  value = [ for idx in sort(keys(aws_subnet.this)) : aws_subnet.this[idx].id ]
}
