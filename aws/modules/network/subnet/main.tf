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
    map_public_ip_on_launch = bool
  }))
}

resource "aws_subnet" "this" {
  for_each = toset(var.subnets)

  vpc_id = var.vpc_id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags = {
    "Name" = each.value.name
  }
}
