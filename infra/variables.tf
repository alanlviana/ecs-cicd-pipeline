variable "image" {
    description = "Fully qualified Docker image name"
    type        = string
}

variable "cluster_name" {
    description = "The name of the cluster"
    type        = string
}

variable "app_name" {
    description = "The name of the app"
    type        = string
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC"
    type        = string
    default = "10.0.0.0/16"
}