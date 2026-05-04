# module "databases" {
#   for_each = var.databases
#   source   = "./modules/rds"
#
#   env        = var.env
#   subnet_ids = var.subnets
#   kms_key_id = var.kms_key_id
#
#   allocated_storage = each.value["allocated_storage"]
# }
#
#
# module "eks" {
#   source = "./modules/eks"
#
#   env        = var.env
#   subnets    = var.subnets
#   kms_key_id = var.kms_key_id
#
# }

module "network" {
  for_each = var.network
  source   = "./modules/network"

  env = var.env

  vpc_cidr = each.value["vpc_cidr"]
  subnets  = each.value["subnets"]

}


