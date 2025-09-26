data "aws_iam_policy_document" "task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Application task role (your app containers use this)
resource "aws_iam_role" "task_role" {
  name               = "${var.name}-task"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = merge(var.tags, { Name = "${var.name}-task" })
}

# Execution role (pull images from ECR, write logs)
resource "aws_iam_role" "exec_role" {
  name               = "${var.name}-exec"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = merge(var.tags, { Name = "${var.name}-exec" })
}

# Attach AWS managed execution policy (ECR pull + CW logs)
resource "aws_iam_role_policy_attachment" "exec_ecr_logs" {
  role       = aws_iam_role.exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Optional: allow reading from Secrets Manager for app containers
data "aws_iam_policy_document" "secrets_read" {
  count = var.allow_secretsmanager ? 1 : 0
  statement {
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "secrets_read" {
  count  = var.allow_secretsmanager ? 1 : 0
  name   = "${var.name}-secrets-read"
  policy = data.aws_iam_policy_document.secrets_read[0].json
  tags   = merge(var.tags, { Name = "${var.name}-secrets-read" })
}

resource "aws_iam_role_policy_attachment" "task_secrets" {
  count      = var.allow_secretsmanager ? 1 : 0
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.secrets_read[0].arn
}
