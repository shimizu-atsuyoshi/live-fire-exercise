variable "name" {
  description = "vpc name"
  type        = string
}

variable "cidr_block" {
  description = "vpc cidr block"
  type        = string
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "Name" = var.name
  }
}

output "id" {
  value = aws_vpc.this.id
}
