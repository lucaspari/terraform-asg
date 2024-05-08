variable "subnet" {
  description = "my subnets"
  type        = list(string)
  default     = ["subnet-049beeb42dadbf662", "subnet-0405b64aa0eea4e71"]
}

variable "vpc" {
  description = "my default vpc"
  type        = string
  default     = "vpc-0baab4ac02004afff"
}

variable "linux-t3" {
  description = "linux t2.micro"
  type        = string
  default     = "ami-0c0039bfde8cbfe27"
}
