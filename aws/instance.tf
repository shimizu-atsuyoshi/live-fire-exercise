module "ai_ci_db" {
  source             = "./modules/instance/rds"
  vpc_id             = module.vpc.id
  subnet_ids         = module.public_subnets.ids
  cluster_identifier = "ai-ci-cluster"
  master_password    = var.database_master_password
  database_name      = var.database_name
  ingress = {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [
      module.dms.security_group_id,
    ]
  }
}

module "bin_db" {
  source             = "./modules/instance/rds"
  vpc_id             = module.vpc.id
  subnet_ids         = module.public_subnets.ids
  cluster_identifier = "bin-cluster"
  master_password    = var.database_master_password
  database_name      = var.database_name
  ingress = {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [
      module.dms.security_group_id,
    ]
  }
}
