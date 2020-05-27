# configure AWS provider, version is optional but recommended to use, shared credentials preconfigured via AWS CLI in .aws\credentials will be used -> no explicit credentials cfg required
provider "aws" {
  version   = "~> 2.0"
  region    = var.region

}

#################
### RESOURCES ###
#################

#Define IAM Role first
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

# Define Lambda Python3.6
resource "aws_lambda_function" "greeting" {
  role             = aws_iam_role.lambda_exec_role.arn # reference IAM Role with required permissions
  handler          = "greet_lambda.lambda_handler"
  runtime          = "python3.6"
  filename         = "greet_lambda.zip"
  function_name    = "greeting"
  #source_code_hash = base64sha256(file("greet_lambda.zip"))
}


