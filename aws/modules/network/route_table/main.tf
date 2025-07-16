variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "name" {
  description = "route table name"
  type        = string
}

variable "subnet_ids" {
  description = "subnet ids"
  type        = set(string)
}

variable "gateway_id" {
  description = "gateway id"
  type        = string
}

resource "aws_route_table" "this" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = var.name
  }
}

resource "aws_route_table_association" "this" {
  for_each = var.subnet_ids
  subnet_id = each.value
  route_table_id = aws_route_table.this.id
}

resource "aws_route" "this" {
  route_table_id = aws_route_table.this.id
  gateway_id = var.gateway_id
  destination_cidr_block = "0.0.0.0/0"
}
