/*
variable "iam_policy_name" {
  type = string
}
variable "iam_role_name" {
  type = string
}
variable "iam_profile_name" {
  type = string
}
*/
variable "swa_tenant" {
  type = string
}
variable "bucket_arn" {
  type = string
}

variable "dynamodb_arn" {
  type = string
}

variable "ec2_arn" {
  type = string
  default = "arn:aws-cn:ec2"
}

//variable "dnynamoDB_arn" {
//  type = string
//}
