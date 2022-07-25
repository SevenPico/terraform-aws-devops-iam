variable "principals" {
  type    = map(any)
  default = {}
}

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

variable "env0_enabled" {
  type = bool
  default = false
}

variable "env0_principal" {
  type = string
  default = ""
}

variable "env0_external_id" {
  type = string
  default = ""
}

variable "tfstate_bucket_arn" {
  type = string
}
