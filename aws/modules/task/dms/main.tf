variable "replication_task_id" {
  description = "replication task id"
  type = string
}

variable "replication_instance_arn" {
  description = "replication instance arn"
  type = string
}

variable "source_endpoint_arn" {
  description = "source endpoint arn"
  type = string
}

variable "target_endpoint_arn" {
  description = "target endpoint arn"
  type = string
}

variable "migration_type" {
  description = "migration type"
  type        = string
  default     = "cdc"
}

variable "table_mappings" {
  description = "table mappings"
  type        = string
}

variable "replication_task_settings" {
  description = "eplication task settings"
  type        = string
}

resource "aws_dms_replication_task" "this" {
  replication_task_id      = var.replication_task_id
  replication_instance_arn = var.replication_instance_arn
  source_endpoint_arn = var.source_endpoint_arn
  target_endpoint_arn = var.target_endpoint_arn
  migration_type            = var.migration_type
  table_mappings            = var.table_mappings
  replication_task_settings = var.replication_task_settings
}
