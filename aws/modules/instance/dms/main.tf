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

variable "target_db" {
  description = "target db"
  type = object({
    engine_name = string
    username = string
    password = string
    server_name = string
    port = number
    database_name = string
  })
}

resource "aws_dms_replication_instance" "this" {
  replication_instance_id      = var.replication_instance_id
  replication_instance_class   = "dms.t3.micro"
  allocated_storage            = 8
  publicly_accessible          = false
  multi_az                     = false
  auto_minor_version_upgrade   = false
  replication_subnet_group_id  = aws_dms_replication_subnet_group.this.id
  vpc_security_group_ids       = [aws_security_group.this.id]
  preferred_maintenance_window = "sun:10:30-sun:14:30"
}

resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = "${replication_instance_id}-subnet-group"
  replication_subnet_group_description = "${replication_instance_id} subnet group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "this" {
  name   = "${replication_instance_id}-sg"
  vpc_id = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${replication_instance_id}-sg"
  }
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

resource "aws_dms_endpoint" "target" {
  endpoint_type = "target"
  endpoint_id   = "${var.replication_instance_id}-target-endpoint"
  engine_name   = var.target_db.engine_name
  username      = var.target_db.username
  password      = var.target_db.password
  server_name   = var.target_db.server_name
  port          = var.target_db.port
  database_name = var.target_db.database_name
}
