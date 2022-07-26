output "role_arn" {
  value = join("", aws_iam_role.deployment[*].arn)
}

output "role_name" {
  value = join("", aws_iam_role.deployment[*].name)
}

output "group_name" {
  value = join("", aws_iam_group.deployment[*].name)
}

output "group_arn" {
  value = join("", aws_iam_group.deployment[*].arn)
}
