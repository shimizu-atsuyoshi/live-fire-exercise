module "vpc" {
  source = "./modules/network/vpc"
  name = "live-fire-exercise"
  cidr_block = var.vpc_cidr_block
}

module "public_subnets" {
  source = "./modules/network/subnet"
  vpc_id = module.vpc.id
  subnets = [
    { name = "live-fire-exercise-public-subnet-a", cidr_block = var.public_subnet_a_cidr_block, availability_zone = "ap-northeast-1a" },
    { name = "live-fire-exercise-public-subnet-c", cidr_block = var.public_subnet_c_cidr_block, availability_zone = "ap-northeast-1c" },
    { name = "live-fire-exercise-public-subnet-d", cidr_block = var.public_subnet_d_cidr_block, availability_zone = "ap-northeast-1d" },
  ]
  map_public_ip_on_launch = true
}

module "private_subnets" {
  source = "./modules/network/subnet"
  vpc_id = module.vpc.id
  subnets = [
    { name = "live-fire-exercise-private-subnet-a", cidr_block = var.private_subnet_a_cidr_block, availability_zone = "ap-northeast-1a" },
    { name = "live-fire-exercise-private-subnet-c", cidr_block = var.private_subnet_c_cidr_block, availability_zone = "ap-northeast-1c" },
    { name = "live-fire-exercise-private-subnet-d", cidr_block = var.private_subnet_d_cidr_block, availability_zone = "ap-northeast-1d" },
  ]
  map_public_ip_on_launch = false
}

module "internet_gateway" {
  source = "./modules/network/internet_gateway"
  vpc_id = module.vpc.id
  name = "live-fire-exercise"
}

module "public_route_table" {
  source = "./modules/network/route_table"
  vpc_id = module.vpc.id
  subnet_ids = module.public_subnets.ids
  gateway_id = module.internet_gateway.id
  with_gateway = true
  name = "live-fire-exercise-public"
}

module "private_route_table" {
  source = "./modules/network/route_table"
  vpc_id = module.vpc.id
  subnet_ids = module.private_subnets.ids
  name = "live-fire-exercise-private"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [module.private_route_table.id]
}
