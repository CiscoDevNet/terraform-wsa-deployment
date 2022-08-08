terraform {
  backend "s3" {
    bucket  = "wsa-terraform-bucket"
    key  =  "datacenter/terraform.tfstate"
  }
}
