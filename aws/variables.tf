variable "vpc_cidr_block" {
  description = "vpc cidr block"
  type        = string
}

variable "public_subnet_a_cidr_block" {
  description = "public subnet a cidr block"
  type        = string
}

variable "public_subnet_c_cidr_block" {
  description = "public subnet c cidr block"
  type        = string
}

variable "public_subnet_d_cidr_block" {
  description = "public subnet d cidr block"
  type        = string
}

variable "private_subnet_a_cidr_block" {
  description = "private subnet a cidr block"
  type        = string
}

variable "private_subnet_c_cidr_block" {
  description = "private subnet c cidr block"
  type        = string
}

variable "private_subnet_d_cidr_block" {
  description = "private subnet d cidr block"
  type        = string
}

variable "database_master_password" {
  description = "database master password"
  type        = string
}

variable "database_name" {
  description = "database name"
  type        = string
}

variable "timezone_batch_cpu" {
  description = "timezone batch cpu"
  type        = string
}

variable "timezone_batch_memory" {
  description = "timezone batch memory"
  type        = string
}
