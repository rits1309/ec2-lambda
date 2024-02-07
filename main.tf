resource "aws_instance" "lambda-exec" {
    ami = "ami-0a7cf821b91bcccbc"
    instance_type = var.instance-type
    key_name = var.key
    subnet_id = var.subnet-id
    vpc_security_group_ids = [var.security-group]
    associate_public_ip_address = true
    tags = {
        Name = "ec2instancelambda"
    }
}
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name="lambda_role"
  }
}
resource "aws_iam_policy" "lambda_policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
          "ec2:Stop*",
          "ec2:Start*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*"
        },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda-attach" {
    role = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_policy.lambda_policy.arn
}
resource "aws_lambda_function" "stopec2_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "stopec2.zip"
  function_name = "stopec2-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "stopec2instance.lambda_handler"
  source_code_hash = filebase64sha256("stopec2.zip")
  runtime = "python3.11"
}
resource "aws_lambda_function" "startec2_lambda" {
    filename      = "startec2.zip"
    function_name = "startec2-funcction"
    role          =  aws_iam_role.lambda_role.arn
    handler       = "startec2instance.lambda_handler"
    source_code_hash = filebase64sha256("startec2.zip")
    runtime = "python3.11"  
}
resource "aws_cloudwatch_event_rule" "stopec2_schedule" {
    name = "stop-ec2"
    schedule_expression = "cron(0 17 ? * 6 *)"
}
resource "aws_cloudwatch_event_target" "stopec2_target" {
    rule = aws_cloudwatch_event_rule.stopec2_schedule.name
    target_id = "lambda"
    arn = aws_lambda_function.stopec2_lambda.arn
}
resource "aws_lambda_permission" "allow_cloudwatch_stop" {
    statement_id  = "AllowExecutionFromCloudWatch"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.stopec2_lambda.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.stopec2_schedule.arn 
}
resource "aws_cloudwatch_event_rule" "start_ec2" {
  name                = "start_ec2_schedule"
  schedule_expression = "cron(30 2 ? * 2 *)" 
}
resource "aws_cloudwatch_event_target" "start_ec2_target" {
  rule      = aws_cloudwatch_event_rule.start_ec2.name
  target_id = "lambda"
  arn       = aws_lambda_function.startec2_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.startec2_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_ec2.arn
}


