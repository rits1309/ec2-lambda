output "ec2" {
  value = aws_instance.lambda-exec
}
output "role" {
    value = aws_iam_role.lambda_role
  
}
output "policy" {
    value = aws_iam_policy.lambda_policy
  
}