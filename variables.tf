variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "demo-eks-cluster"
}

variable "vpc_name" {
  default = "demo-eks-vpc"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
