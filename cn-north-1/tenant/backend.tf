
terraform {
  backend "s3" {
    region         = "ap-south-1"
    bucket         = "mumbai-terraform-bucket"
    key            = "enhancement/terraform.tfstate"
  }
}

