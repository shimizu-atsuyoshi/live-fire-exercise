variable "image" {
  description = "ecr repository uri"
  type        = string
}

variable "name" {
  description = "job definition name"
  type        = string
}

variable "command" {
  description = "execute command"
  type        = list(string)
}

variable "cpu" {
  description = "cpu size for job"
  type        = string
}

variable "memory" {
  description = "memory size for job"
  type        = string
}

variable "secrets" {
  description = "secrets for job"
  type        = list(
    object({
      name      = string
      valueFrom = string
    })
  )
  default     = []
}

variable "environment" {
  description = "environment for job"
  type        = list(
    object({
      name  = string
      value = string
    })
  )
  default     = []
}

resource "aws_ecr_repository" "this" {
  name                 = var.image
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/batch/${var.name}"
  retention_in_days = 7
}

resource "aws_iam_role" "task_role" {
  name               = "${var.name}-task-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "task_role_policy" {
  name = "${var.name}-task-role-policy"
  role = aws_iam_role.task_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ],
        "Resource" : [
          aws_cloudwatch_log_group.this.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "execution_role" {
  name               = "${var.name}-execution-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_batch_job_definition" "this" {
  name                  = var.name
  type                  = "container"
  platform_capabilities = ["FARGATE"]
  ecs_properties        = jsonencode({
    taskProperties = [
      {
        taskRoleArn      = aws_iam_role.task_role.arn
        executionRoleArn = aws_iam_role.execution_role.arn
        platformVersion  = "LATEST"
        containers = [
          {
            name        = var.name
            image       = var.image
            command     = var.command
            secrets     = var.secrets
            environment = var.environment
            resourceRequirements = [
              {
                type  = "VCPU"
                value = var.cpu
              },
              {
                type = "MEMORY"
                value = var.memory
              }
            ]
            logConfiguration = {
              logFriver = "awslogs",
              options = {
                awslogs-group         = aws_cloudwatch_log_group.this.name
                awslogs-region        = "ap-northeast-1"
                awslogs-stream-prefix = "${var.name}-job"
              }
            }
          }
        ]
      }
    ]
  })
}
