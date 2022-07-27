resource "aws_s3" "s3_bucket" {
  bucket = "testing-tf-code-bucket"
  tags = {
    Name        = "s3_bucket"
    SWATenant = var.swatenant
  }
}

resource "aws_s3_bucket_policy" "attaching_something" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = aws_iam_policy.S3_policy.id
}

resource "aws_iam_role_policy" "my-s3-read-policy" {
  name   = "inline-policy-name-that-will-show-on-aws"
  role   = "some-existing-iam-role-name"
  policy = data.aws_iam_policy_document.s3_read_permissions.json
}

data "aws_iam_policy_document" "s3_read_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketPolicy",
      "s3:PutBucketPolicy"
    ]

    resources = ["arn:aws-cn:s3:::bckt-for-s3-restricted-access/*",
                 "arn:aws-cn:s3:::bckt-for-s3-restricted-access". ]
  }
}

