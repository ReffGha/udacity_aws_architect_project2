# TODO: Define the output variable for the lambda function.
output "lambda_function" {
  value = aws_lambda_function.greeting
  description = "Output of the lamda function name"
}