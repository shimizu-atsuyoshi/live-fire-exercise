module "bastion" {
  source                      = "./modules/instance/ec2"
  name                        = "live-fire-exercise-bastion"
  vpc_id                      = module.vpc.id
  subnet_id                   = module.private_subnets.ids[0]
  associate_public_ip_address = true
  ingress = {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = []
  }
}

module "source_db" {
  source             = "./modules/instance/rds"
  vpc_id             = module.vpc.id
  subnet_ids         = module.private_subnets.ids
  cluster_identifier = "source-cluster"
  master_password    = var.database_master_password
  database_name      = var.database_name
  ingress = {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = []
  }
}

module "destination_db" {
  source             = "./modules/instance/rds"
  vpc_id             = module.vpc.id
  subnet_ids         = module.private_subnets.ids
  cluster_identifier = "destination-cluster"
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

module "dms" {
  source                  = "./modules/instance/dms"
  vpc_id                  = module.vpc.id
  subnet_ids              = module.private_subnets.ids
  replication_instance_id = "live-fire-exercise"
  source_db = {
    engine_name   = "aurora"
    username      = module.source_db.master_username
    password      = var.database_master_password
    server_name   = module.source_db.endpoint
    port          = module.source_db.port
    database_name = module.source_db.database_name
  }
  target_db = {
    engine_name   = "aurora"
    username      = module.destination_db.master_username
    password      = var.database_master_password
    server_name   = module.destination_db.endpoint
    port          = module.destination_db.port
    database_name = module.destination_db.database_name
  }
}
