variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "subnet_ids" {
  description = "subnet ids"
  type        = list(string)
}

variable "replication_instance_id" {
  description = "replication instance id"
  type        = string
}

variable "source_db" {
  description = "source db"
  type = object({
    engine_name = string
    username = string
    password = string
    server_name = string
    port = number
    database_name = string
  })
}

variable "target_s3" {
  description = "target s3"
  type = object({
    bucket = string
  })
}

resource "aws_dms_replication_instance" "this" {
  replication_instance_id      = var.replication_instance_id
  replication_instance_class   = "dms.t3.small"
  allocated_storage            = 8
  publicly_accessible          = false
  multi_az                     = false
  auto_minor_version_upgrade   = false
  replication_subnet_group_id  = aws_dms_replication_subnet_group.this.id
  vpc_security_group_ids       = [aws_security_group.this.id]
  preferred_maintenance_window = "sun:10:30-sun:14:30"
}

resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = "${var.replication_instance_id}-subnet-group"
  replication_subnet_group_description = "${var.replication_instance_id} subnet group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "this" {
  name   = "${var.replication_instance_id}-sg"
  vpc_id = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.replication_instance_id}-sg"
  }
}

resource "aws_s3_bucket" "dms_target" {
  bucket = var.target_s3.bucket

  tags = {
    Name = var.target_s3.bucket
  }
}

resource "aws_iam_role" "dms_target_s3_endpoint_role" {
  name = "dms-target-s3-endpoint-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "dms.ap-northeast-1.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "dms_target_s3_endpoint_role_policy" {
  name = "dms-target-s3-endpoint-role-policy"
  role = aws_iam_role.dms_target_s3_endpoint_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutObjectTagging",
        ],
        Resource = [
          "${aws_s3_bucket.dms_target.arn}/*",
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
        ],
        Resource = [
          "${aws_s3_bucket.dms_target.arn}*",
        ]
      }
    ]
  })
}

resource "aws_dms_endpoint" "source" {
  endpoint_type = "source"
  endpoint_id   = "${var.replication_instance_id}-source-endpoint"
  engine_name   = var.source_db.engine_name
  username      = var.source_db.username
  password      = var.source_db.password
  server_name   = var.source_db.server_name
  port          = var.source_db.port
  database_name = var.source_db.database_name
}

resource "aws_dms_s3_endpoint" "target" {
  endpoint_type           = "target"
  endpoint_id             = "${var.replication_instance_id}-target-endpoint"
  bucket_name             = var.target_s3.bucket
  service_access_role_arn = aws_iam_role.dms_target_s3_endpoint_role.arn
  cdc_max_batch_interval  = 60
  data_format             = "csv"
}

output "replication_instance_arn" {
  value = aws_dms_replication_instance.this.replication_instance_arn
}

output "source_endpoint_arn" {
  value = aws_dms_endpoint.source.endpoint_arn
}

output "target_endpoint_arn" {
  value = aws_dms_s3_endpoint.target.endpoint_arn
}

output "security_group_id" {
  value = aws_security_group.this.id
}
