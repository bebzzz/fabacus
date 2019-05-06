variable "region" {
  default = "us-east-1"
}

variable "images" {
  description = "Amazon Linux AMI 2018.03.0 (HVM), SSD Volume Type  for different Regions"
  type        = "map"

  default = {
    "us-east-1"      = "ami-0080e4c5bc078760e"
    "us-east-2"      = "ami-0cd3dfa4e37921605"
    "us-west-1"      = "ami-0ec6517f6edbf8044"
    "us-west-2"      = "ami-01e24be29428c15b2"
    "ap-south-1"     = "ami-0ad42f4f66f6c1cc9"
    "ap-northeast-2" = "ami-00dc207f8ba6dc919"
    "ap-southeast-1" = "ami-05b3bcf7f311194b3"
    "ap-southeast-2" = "ami-02fd0b06f06d93dfc"
    "ap-northeast-1" = "ami-00a5245b4816c38e6"
    "ca-central-1"   = "ami-07423fb63ea0a0930"
    "eu-central-1"   = "ami-0cfbf4f6db41068ac"
    "eu-west-1"      = "ami-08935252a36e25f85"
    "eu-west-2"      = "ami-01419b804382064e4"
    "eu-west-3"      = "ami-0dd7e7ed60da8fb83"
    "eu-north-1"     = "ami-86fe70f8"
    "sa-east-1"      = "ami-05145e0b28ad8e0b2"
  }
}

variable "vpc_cidr_block" {
  default = "10.10.0.0/16"
}

variable "vpc_subnet" {
  type = "map"

  default = {
    "public"   = "10.10.1.0/24"
    "public2"  = "10.10.2.0/24"
    "private"  = "10.10.3.0/24"
    "private2" = "10.10.4.0/24"
  }
}

variable "instance_type" {
  default = "t2.micro"
}
