module "vpc" {
  source = "./modules/network/vpc"
  name = "live-fire-exercise"
  cidr_block = var.vpc_cidr_block
}

module "public_subnets" {
  source = "./modules/network/subnet"
  vpc_id = module.vpc.id
  subnets = [
    { name = "public_subnet_a", cidr_block = var.public_subnet_a_cidr_block, availability_zone = "ap-northeast-1a" },
    { name = "public_subnet_c", cidr_block = var.public_subnet_c_cidr_block, availability_zone = "ap-northeast-1c" },
    { name = "public_subnet_d", cidr_block = var.public_subnet_d_cidr_block, availability_zone = "ap-northeast-1d" },
  ]
  map_public_ip_on_launch = true
}

module "private_subnets" {
  source = "./modules/network/subnet"
  vpc_id = module.vpc.id
  subnets = [
    { name = "private_subnet_a", cidr_block = var.private_subnet_a_cidr_block, availability_zone = "ap-northeast-1a" },
    { name = "private_subnet_c", cidr_block = var.private_subnet_c_cidr_block, availability_zone = "ap-northeast-1c" },
    { name = "private_subnet_d", cidr_block = var.private_subnet_d_cidr_block, availability_zone = "ap-northeast-1d" },
  ]
  map_public_ip_on_launch = false
}
