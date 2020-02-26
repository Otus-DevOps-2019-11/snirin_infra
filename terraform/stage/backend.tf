terraform {
  backend "gcs" {
    bucket = "storage-bucket-reddit-app"
    path   = "stage/terraform.tfstate"
  }
}
