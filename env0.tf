# ------------------------------------------------------------------------------
# env0
# ------------------------------------------------------------------------------
module "env0_meta" {
  source  = "registry.terraform.io/cloudposse/label/null"
  version = "0.25.0"
  context = module.this.context
  enabled = module.this.enabled && var.env0_enabled
}


# ------------------------------------------------------------------------------
# env0 Assume Role Policy
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "env0_assume_role" {
  count = module.env0_meta.enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.env0_principal]
    }
    condition {
      test = "StringEquals"
      variable = "sts:ExternalId"
      values = [var.env0_external_id]
    }
  }
}


# ------------------------------------------------------------------------------
# env0 Cost Role
# ------------------------------------------------------------------------------
resource "aws_iam_role" "env0_cost" {
  count = module.env0_meta.enabled ? 1 : 0
  tags  = module.env0_meta.tags
  name  = "CostRole"

  assume_role_policy  = one(data.aws_iam_policy_document.env0_assume_role[*].json)
  max_session_duration = (60 * 60 * 12) # seconds -> 12 hours

  inline_policy {
    name   = "cost"
    policy = one(data.aws_iam_policy_document.env0_cost[*].json)
  }
}

data "aws_iam_policy_document" "env0_cost" {
  count = module.env0_meta.enabled ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["ce:GetCostAndUsage"]
    resources = ["*"]
  }
}
