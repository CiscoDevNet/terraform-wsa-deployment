
terraform {
  backend "s3" {
    region         = "cn-north-1"
    bucket         = "wsa-terraform-bucket"
    key            = "tenant159/terraform.tfstate"
  }
}

