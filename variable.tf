variable "region" {
    default = "ap-south-1" 
}
# variable "ami" {
#     default = "ami-06aa3f7caf3a30282"
# }
variable "instance-type" {
    default = "t2.micro"
}
variable "security-group" {
  default = "sg-0ff577ba3741b167b"

  type = string
}
variable "subnet-id" {
    default = "subnet-08da9265d5b023a6b"
  
}
variable "key" {
    default = "terraform-ap-south-1" 
}
 variable "ins_count" {
    default = 1
}
variable "name" {
    default = "ec2-lambda"
  
}
variable "default_ec2_tags" {
  type        = map(string)
  default = {
    managed_by   = "terraform"
    Environment  = "Dev"
  }
}