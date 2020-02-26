terraform {
  required_version = "~>0.12.8"
}

provider "google" {
  version = "~> 2.15"
  project = var.project
  region  = var.region
}

module "app" {
  source             = "../modules/app"
  public_key_path    = var.public_key_path
  private_key_path   = var.private_key_path
  zone               = var.zone
  app_disk_image     = var.app_disk_image
  env_type           = "prod"
  db_url             = "${module.db.db_internal_ip}"
  modules_depends_on = [module.vpc, module.db]
  use_provisioners   = true
}

module "db" {
  source             = "../modules/db"
  public_key_path    = var.public_key_path
  private_key_path   = var.private_key_path
  zone               = var.zone
  db_disk_image      = var.db_disk_image
  env_type           = "prod"
  modules_depends_on = [modules.vpc]
  use_provisioners   = true
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["91.193.179.239/32"]
}
