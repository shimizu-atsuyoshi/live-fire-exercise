variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "subnet_id" {
  description = "subnet id"
  type        = string
}

variable "associate_public_ip_address" {
  description = "associate public ip address"
  type        = bool
}

variable "name" {
  description = "instance name"
  type        = string
}

variable "public_key" {
  description = "public key file path"
  type        = string
}

variable "ingress" {
  description = "security group ingress"
  type = object({
    from_port       = number
    to_port         = number
    protocol        = string
    security_groups = list(string)
  })
}

resource "aws_instance" "this" {
  ami           = "ami-054400ced365b82a0"
  instance_type = "t3.micro"
  subnet_id = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name = aws_key_pair.this.key_name
  tags = {
    "Name" = var.name
  }
}

resource "aws_key_pair" "this" {
  key_name = "${var.name}-key"
  public_key = file(var.public_key)
}

resource "aws_security_group" "this" {
  name = "${var.name}-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = var.ingress.from_port
    to_port         = var.ingress.to_port
    protocol        = var.ingress.protocol
    security_groups = var.ingress.security_groups
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.name}-sg"
  }
}
