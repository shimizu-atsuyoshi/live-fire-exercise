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
  ami                         = "ami-054400ced365b82a0"
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = [aws_security_group.this.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  tags = {
    "Name" = var.name
  }
}

resource "aws_security_group" "this" {
  name   = "${var.name}-sg"
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

resource "aws_iam_role" "this" {
  name = "${var.name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-role-profile"
  role = aws_iam_role.this.name
}
