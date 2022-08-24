resource "aws_dynamodb_table" "dynamodb" {
  name           = "${var.swa_tenant}-swa-id-db"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = var.swa_tenant

  attribute {
    name = var.swa_tenant
    type = "S"
  }

  tags = {
        Name = var.swa_tenant
  }
}
