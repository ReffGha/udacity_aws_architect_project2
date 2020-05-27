# configure AWS provider, version is optional but recommended to use, shared credentials preconfigured via AWS CLI in .aws\credentials will be used -> no explicit credentials cfg required
provider "aws" {
  version   = "~> 2.0"
  region    = var.region

}

#################
### RESOURCES ###
#################

# Define IAM Role first
resource "aws_iam_role" "lambda_exec_role" {
  name        = "lambda_exec"
  path        = "/"
  description = "Allows Lambda Function to call AWS services."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
      }
    
  ]
}
EOF
}

# Define Policy
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "greeting" {
  name              = "/aws/lambda/greeting"
  retention_in_days = 14
}

# Define Lambda Python3.6
resource "aws_lambda_function" "greeting" {
  role             = aws_iam_role.lambda_exec_role.arn # reference IAM Role with required permissions
  handler          = "greet_lambda.lambda_handler"
  runtime          = "python3.6"
  filename         = "greet_lambda.zip"
  function_name    = "greeting"
  #source_code_hash = base64sha256(file("greet_lambda.zip"))
  depends_on = ["aws_iam_role_policy_attachment.lambda_logs", "aws_cloudwatch_log_group.greeting"]
  environment {
    variables = {
      greeting = "TestGreeting"
    }
  }
}

