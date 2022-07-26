variable "policy_arns" {
  type    = list(string)
  default = []
}

variable "inline_policies" {
  description = "map name:policy to attach as inline policies to the role"
  type        = map(any)
  default     = {}
}

variable "group_enabled" {
  type = bool
  default = false
}

variable "role_name" {
  type = string
  default = "DeploymentRole"
}

variable "group_name" {
  type = string
  default = "devops"
}

variable "principals" {
  type    = map(any)
  default = {}
}


variable "foreign_principal_enabled" {
  type = bool
  default = false
}

variable "foreign_principal" {
  type = string
  default = ""
}

variable "foreign_principal_external_id" {
  type = string
  default = ""
}

variable "tfstate_bucket_arn" {
  type = string
}
