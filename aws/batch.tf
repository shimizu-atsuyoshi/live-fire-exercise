module "timezone_compute" {
  source     = "./modules/batch/compute"
  name       = "timezone"
  vpc_id     = module.vpc.id
  subnet_ids = module.private_subnets.ids
}

module "timezone_job_definition" {
  source      = "./modules/batch/job_definition"
  image       = "timezone-batch"
  name        = "timezone"
  command     = ["/opt/timezone/batch"]
  cpu         = var.timezone_batch_cpu
  memory      = var.timezone_batch_memory
  environment = [
    { name: "TZ", value: "Asia/Tokyo" }
  ]
}
