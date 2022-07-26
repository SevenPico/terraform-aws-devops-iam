# ------------------------------------------------------------------------------
# IAM Meta
# ------------------------------------------------------------------------------
module "role_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
  enabled = module.this.enabled
  name    = var.role_name
}

module "group_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
  enabled = module.this.enabled && var.group_enabled
  name    = var.group_name
}

module "foriegn_principal_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.role_meta.context
  enabled = module.role_meta.enabled && var.foreign_principal_enabled
}


# ------------------------------------------------------------------------------
# IAM Role
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "assume_role" {
  count                   = module.role_meta.enabled ? 1 : 0
  source_policy_documents = compact([one(data.aws_iam_policy_document.foriegn_principal_assume_role[*].json)])

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
  count = module.role_meta.enabled ? 1 : 0
  tags  = module.role_meta.tags

  name        = var.role_name
  description = "Allows access to run infrastructure deployments."

  managed_policy_arns  = distinct(concat(["arn:aws:iam::aws:policy/AdministratorAccess"], var.policy_arns))
  assume_role_policy   = one(data.aws_iam_policy_document.assume_role[*].json)
  max_session_duration = (60 * 60 * 12) # seconds -> 12 hours

  dynamic "inline_policy" {
    for_each = merge(var.inline_policies, {
      deployment-tfstate-access : one(data.aws_iam_policy_document.tfstate[*].json)
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
# IAM Group
# ------------------------------------------------------------------------------
resource "aws_iam_group" "deployment" {
  count = module.group_meta.enabled ? 1 : 0
  name  = module.group_meta.id
}

resource "aws_iam_group_policy" "assume_deployer_role" {
  count  = module.group_meta.enabled ? 1 : 0
  name   = "${module.group_meta.id}-policy"
  group  = one(aws_iam_group.deployment[*].id)
  policy = one(data.aws_iam_policy_document.assume_deployment_role[*].json)
}

data "aws_iam_policy_document" "assume_deployment_role" {
  count = module.group_meta.enabled ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    resources = [
      "arn:aws:iam::*:role/${var.role_name}"
    ]
  }
}


# ------------------------------------------------------------------------------
# foriegn_principal Assume Role Policy
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "foriegn_principal_assume_role" {
  count = module.foriegn_principal_meta.enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.foreign_principal]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.foreign_principal_external_id]
    }
  }
}
