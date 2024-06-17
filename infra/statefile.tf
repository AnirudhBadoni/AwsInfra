terraform {
  backend "s3" {
    bucket  = "vegeta-terraform-remote-state-2024"
    key     = "infra.tfstate"
    region  = "ap-south-1"
    profile = "default"
    dynamodb_table = "vegeta-terraform-remote-state-table-2024"
  }
}
