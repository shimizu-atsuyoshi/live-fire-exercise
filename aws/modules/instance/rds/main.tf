variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "subnet_ids" {
  description = "subnet ids"
  type        = list(string)
}

variable "cluster_identifier" {
  description = "cluster identifier"
  type        = string
}

variable "master_password" {
  description = "master password"
  type        = string
}

variable "database_name" {
  description = "database name"
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

resource "aws_rds_cluster" "this" {
  cluster_identifier              = var.cluster_identifier
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.mysql_aurora.3.08.2"
  master_username                 = "root"
  master_password                 = var.master_password
  database_name                   = var.database_name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_subnet_group_name            = aws_db_subnet_group.this.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.id
  skip_final_snapshot             = true
}


resource "aws_security_group" "this" {
  name   = "${var.cluster_identifier}-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = var.ingress.from_port
    to_port         = var.ingress.to_port
    protocol        = var.ingress.protocol
    security_groups = var.ingress.security_groups
  }
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.cluster_identifier}-sg"
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.cluster_identifier}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_rds_cluster_instance" "this" {
  count               = 1
  identifier          = "${var.cluster_identifier}-instance"
  cluster_identifier  = aws_rds_cluster.this.id
  engine              = aws_rds_cluster.this.engine
  engine_version      = aws_rds_cluster.this.engine_version
  instance_class      = "db.t3.medium"
  publicly_accessible = true
}

resource "aws_rds_cluster_parameter_group" "this" {
  name   = "${var.cluster_identifier}-parameter-group"
  family = "aurora-mysql8.0"

  parameter {
    name         = "binlog_format"
    value        = "ROW"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "binlog_row_image"
    value        = "FULL"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }

  tags = {
    "Name": "${var.cluster_identifier}-parameter-group"
  }
}

output "master_username" {
  value = aws_rds_cluster.this.master_username
}

output "endpoint" {
  value = aws_rds_cluster.this.endpoint
}

output "port" {
  value = aws_rds_cluster.this.port
}

output "database_name" {
  value = aws_rds_cluster.this.database_name
}
