data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_event_rule" "asgevents" {
  name        = "${var.swa_tenant}-ec2-scaling-events"
  description = "Capture all EC2 scaling events"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.autoscaling"
  ],
  "detail-type": [
    "EC2 Instance Launch Successful",
    "EC2 Instance Terminate Successful",
    "EC2 Instance Launch Unsuccessful",
    "EC2 Instance Terminate Unsuccessful",
    "EC2 Instance-launch Lifecycle Action",
    "EC2 Instance-terminate Lifecycle Action"
],
"detail": {
    "AutoScalingGroupName": [
        "${var.swa_tenant}-dp-ASG",
        "${var.swa_tenant}-cp-ASG"
   ]
  }
}
PATTERN
}

resource "aws_cloudwatch_log_group" "asglog_group" {
  name              = "/aws/events/${var.swa_tenant}-asglifecycleevents"
  retention_in_days = 90
}

data "aws_iam_policy_document" "asglog_policy_document" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    resources = [
      "${aws_cloudwatch_log_group.asglog_group.arn}:*"
    ]

    principals {
      identifiers = ["events.amazonaws.com", "delivery.logs.amazonaws.com"]
      type        = "Service"
    }

    condition {
      test     = "ArnEquals"
      values   = [aws_cloudwatch_event_rule.asgevents.arn]
      variable = "aws:SourceArn"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "asgcloudwatch_policy" {
  policy_document = data.aws_iam_policy_document.asglog_policy_document.json
  policy_name     = "${var.swa_tenant}-cloudwatch-asgpolicy" 
}

resource "aws_cloudwatch_event_target" "asgevent_target" {
  rule = aws_cloudwatch_event_rule.asgevents.name
  arn  = aws_cloudwatch_log_group.asglog_group.arn
}

resource "aws_sns_topic" "user_updates" {
  name = "${var.swa_tenant}_web_alert"
  display_name = "Alert!!"
}


resource "aws_sns_topic_policy" "swa_sns_topic_policy" {
  arn = aws_sns_topic.user_updates.arn

  policy = data.aws_iam_policy_document.swa_sns_topic_policy_document.json
}

data "aws_iam_policy_document" "swa_sns_topic_policy_document" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
        "SNS:Publish",
        "SNS:RemovePermission",
        "SNS:SetTopicAttributes",
        "SNS:DeleteTopic",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:AddPermission",
        "SNS:Subscribe"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.user_updates.arn,
    ]

    sid = "__default_statement_ID"
  }
  statement {
    actions = [
        "SNS:Subscribe",
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.user_updates.arn,
    ]

    sid = "__console_statement_ID"
  }
  statement {
    actions = [
        "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.user_updates.arn,
    ]

    sid = "__console_statement_12"
  }
}
