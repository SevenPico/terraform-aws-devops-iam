locals {
  deployment_role_name = "DeploymentRole" # Hard-coded for consistency across accounts
}

# ------------------------------------------------------------------------------
# Deployment Role
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "assume_role" {
  count = module.this.enabled ? 1 : 0
  source_policy_documents = compact([one(data.aws_iam_policy_document.env0_assume_role[*].json)])

  dynamic "statement" {
    for_each = var.principals
    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type        = statement.key
        identifiers = statement.value
      }
    }
  }
}

resource "aws_iam_role" "deployment" {
  count = module.this.enabled ? 1 : 0
  tags  = module.this.tags
  name  = local.deployment_role_name

  managed_policy_arns = distinct(concat(["arn:aws:iam::aws:policy/AdministratorAccess"], var.policy_arns))
  assume_role_policy  = one(data.aws_iam_policy_document.assume_role[*].json)
  max_session_duration = (60 * 60 * 12) # seconds -> 12 hours

  dynamic "inline_policy" {
    for_each = merge(var.inline_policies, {
      deployment-tfstate-access: one(data.aws_iam_policy_document.tfstate[*].json)
    })
    content {
      name   = inline_policy.key
      policy = inline_policy.value
    }
  }
}

data "aws_iam_policy_document" "tfstate" {
  statement {
    effect  = "Allow"
    actions = ["s3:Put*", "s3:Get*", "s3:*Object", "s3:List*"]
    resources = [
      var.tfstate_bucket_arn,
      "${var.tfstate_bucket_arn}/*",
    ]
  }
}


# ------------------------------------------------------------------------------
# Deployer Group
# ------------------------------------------------------------------------------
module "group_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
  enabled = module.this.enabled && var.group_enabled
}

resource "aws_iam_group" "deployers" {
  count = module.group_meta.enabled ? 1 : 0
  name  = module.group_meta.id
}

resource "aws_iam_group_policy" "assume_deployer_role" {
  count  = module.group_meta.enabled ? 1 : 0
  name   = "${module.group_meta.id}-policy"
  group  = one(aws_iam_group.deployers[*].id)
  policy = one(data.aws_iam_policy_document.assume_deployer_role[*].json)
}

data "aws_iam_policy_document" "assume_deployer_role" {
  count = module.group_meta.enabled ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::*:role/${local.deployment_role_name}"
    ]
  }
}
