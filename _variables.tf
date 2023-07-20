## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./_variables.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

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
  type    = bool
  default = false
}

variable "role_name" {
  type    = string
  default = "DevOpsRole"
}

variable "group_name" {
  type    = string
  default = "devops-users"
}

variable "principals" {
  type    = map(any)
  default = {}
}


variable "foreign_principal_enabled" {
  type    = bool
  default = false
}

variable "foreign_principal" {
  type    = string
  default = ""
}

variable "foreign_principal_external_id" {
  type    = string
  default = ""
}

variable "tfstate_bucket_arn" {
  type = string
}
