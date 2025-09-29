variable "name" {
  description = "name for compute"
  type        = string
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "subnet_ids" {
  description = "subnet ids"
  type        = list(string)
}

resource "aws_iam_role" "this" {
  name = "${var.name}-service-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "batch.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "security group for ${var.name} batch compute"
  vpc_id      = var.vpc_id
  egress      = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_batch_compute_environment" "this" {
  type = "MANAGED"
  service_role = aws_iam_role.this.arn
  compute_resources {
    type = "FARGATE"
    max_vcpus = 16
    subnets = var.subnet_ids
    security_group_ids = [
      aws_security_group.this.id
    ]
  }
}

resource "aws_batch_job_queue" "this" {
  name     = var.name
  state    = "ENABLED"
  priority = 1
  compute_environment_order {
    order               = 1
    compute_environment = aws_batch_compute_environment.this.arn
  }
}
