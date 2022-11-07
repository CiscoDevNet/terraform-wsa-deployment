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
        Name = "${var.swa_tenant}_swa_id_db"
  }
}


### Conctructing ARN for to pass the value in IAM module

locals {
construct_arn1 = replace(aws_dynamodb_table.dynamodb.arn, "dynamodb", "ec2")
construct_arn2 = split(":", local.construct_arn1)
}

output "arn" {
  value = "${local.construct_arn2[0]}:${local.construct_arn2[1]}:${local.construct_arn2[2]}:${local.construct_arn2[3]}:${local.construct_arn2[4]}"
}
