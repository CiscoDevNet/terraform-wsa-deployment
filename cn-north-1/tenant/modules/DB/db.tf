resource "aws_dynamodb_table" "dynamodb" {
  name           = "${var.swa_tenant}-swa-id-db"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "swa_release_tag"

  attribute {
    name = "swa_release_tag"
    type = "S"
  }
  
  tags = {
        Name = "${var.swa_tenant}-swa-id-db"
  }
}
