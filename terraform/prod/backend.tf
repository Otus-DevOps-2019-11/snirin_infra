terraform {
  backend "gcs" {
    bucket = "storage-bucket-reddit-app"
    path   = "prod/terraform.tfstate"
  }
}
