module "actress_ref" {
  source = "./modules/task/dms"
  replication_task_id       = "actress-ref"
  replication_instance_arn  = module.dms.replication_instance_arn
  source_endpoint_arn       = module.dms.source_endpoint_arn
  target_endpoint_arn       = module.dms.target_endpoint_arn
  table_mappings            = file("${path.module}/table_mappings/actress_ref.json")
  replication_task_settings = file("${path.module}/replication_task_settings.json")
}

module "sample" {
  source = "./modules/task/dms"
  replication_task_id       = "sample"
  replication_instance_arn  = module.dms.replication_instance_arn
  source_endpoint_arn       = module.dms.source_endpoint_arn
  target_endpoint_arn       = module.dms.target_endpoint_arn
  table_mappings            = file("${path.module}/table_mappings/sample.json")
  replication_task_settings = file("${path.module}/replication_task_settings.json")
}
