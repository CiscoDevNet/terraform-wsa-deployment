

##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block creates the IAM policy
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##


resource "aws_iam_policy" "ec2_policy" {
  name = "${var.swa_tenant}-policy"
  path = "/"
  description = "Describe instances Policy for Consul AutoJoin Cluster"
  policy = jsonencode({
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ec2:DescribeInstances",
            "Resource": "*"
        },
    ]
  })

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
                "arn:aws-cn:ec2:*:710117294258:instance/*",
                "arn:aws-cn:ec2:*:710117294258:elastic-ip/*",
                "arn:aws-cn:ec2:*:710117294258:network-interface/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAddresses",
            ],
            "Resource": "*"
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
  name = "S3_terraform_policy"
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

resource "aws_iam_policy_attachment" "s3_attachment" {
  name = "Attaching to S3"
  roles = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.s3_policy.arn
}

##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##
#INFO: the following resource block attaches the policy to the role
##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##--##

resource "aws_iam_policy_attachment" "ec2_instances" {
  name = "Attaching to instances"
  roles = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.ec2_policy.arn
}


resource "aws_iam_policy_attachment" "eip_policy_attach" {
  name = "Attaching to instances"
  roles = [aws_iam_role.ec2_role.name]
  policy_arn = aws_iam_policy.eip_policy.arn
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
