variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "name" {
  description = "vpc name"
  type        = string
}

resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = var.name
  }
}

output "id" {
  value = aws_internet_gateway.this.id
}
