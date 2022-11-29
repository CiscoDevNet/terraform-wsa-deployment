output "launch_template_arn" {
  value = aws_launch_template.wsa_autoscale.arn
}

output "swa_nlb" {
  value = aws_lb.swa_nlb.id
}
