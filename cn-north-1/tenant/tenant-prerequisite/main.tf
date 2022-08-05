
data "aws_region" "current" {}

resource "aws_s3_bucket" "wsa_bucket" {
  bucket = lower("${var.swa_tenant}-${data.aws_region.current.name}-bucket")
 // region = data.aws_region.current.name
  acl    = "private"
  tags = {
    "SWATenant" = "${var.swa_tenant}"
  }
}
resource "aws_s3_bucket_public_access_block" "access" {
  bucket = aws_s3_bucket.wsa_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


