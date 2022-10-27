

##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the IAM policy
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

data "aws_region" "current_region" {
}

resource "aws_iam_policy" "eip_policy" {
  name = "${var.swa_tenant}-eip-policy"
  path = "/"
  description = "creating eip policy"
  policy = jsonencode({
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DisassociateAddress",
                "ec2:AssociateAddress"
            ],
            "Resource": [
                "${var.arn}:instance/*",
                "${var.arn}:elastic-ip/*",
                "${var.arn}:network-interface/*"
            ]
        },
    ]
  })

}

resource "aws_iam_policy" "ec2_policy" {
  name = "${var.swa_tenant}-ec2-policy"
  path = "/"
  description = "creating ec2 policy"
  policy = jsonencode({
  "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAddresses",
                "ec2:DescribeInstances",
                "ec2:DescribeNetworkInterfaces",
                "elasticloadbalancing:DescribeLoadBalancers",
                "cloudwatch:PutMetricData",
                "autoscaling:SetInstanceHealth"
            ],
            "Resource": "*"
        },
    ]
  })

}


resource "aws_iam_policy" "dynamodb_policy" {
  name = "${var.swa_tenant}-dynamodb-policy"
  path = "/"
  description = "dynamodb Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:UpdateItem"
            ],
            "Resource": [
                "${var.dynamodb_arn}"
                ]
        },
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ec2:CreateTags",
            "Resource":  "${var.arn}:instance/*"
        },
    ]
})
}


##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the IAM Role
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##


resource "aws_iam_role" "ec2_role" {
  name = "${var.swa_tenant}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "s3_policy" {
  name = "${var.swa_tenant}-s3-policy"
  path = "/"
  description = "S3 Policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "${var.bucket_arn}",
                "${var.bucket_arn}/*"
                ]
        },
    ]
})
}


##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block attaches the policy to the role
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_iam_policy_attachment" "s3_attachment" {
  name = "Attaching to S3 policy to Role"
  roles = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_policy_attachment" "dynamodb_policy_attach" {
  name = "Attaching dynamodb policy to role"
  roles = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

resource "aws_iam_policy_attachment" "eip_policy_attach" {
  name = "Attaching eip policy to Role"
  roles = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.eip_policy.arn
}

resource "aws_iam_policy_attachment" "ec2_policy_attach" {
  name = "Attaching ec2 policy to Role"
  roles = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}


##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the IAM Instance Profile
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.swa_tenant}-profile"
  role = aws_iam_role.ec2_role.name
}


##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: OUTPUT Values
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##


output "role" {
  value = aws_iam_role.ec2_role.name
}
output "ec2_profile" {
  value = aws_iam_instance_profile.ec2_profile.name
}
