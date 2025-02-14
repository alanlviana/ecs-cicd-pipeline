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

variable "vpc_id" {
    description = "The ID of the VPC"
    type        = string
}

variable "subnet_ids" {
    description = "A list of subnet IDs"
    type        = list(string)
}
