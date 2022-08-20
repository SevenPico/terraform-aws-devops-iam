output "role_arn" {
  value = join("", aws_iam_role.devops[*].arn)
}

output "role_name" {
  value = join("", aws_iam_role.devops[*].name)
}

output "group_name" {
  value = join("", aws_iam_group.devops[*].name)
}

output "group_arn" {
  value = join("", aws_iam_group.devops[*].arn)
}
