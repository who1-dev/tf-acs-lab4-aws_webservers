variable "env" {
  type        = string
  description = "Deployment Environment"
}

variable "default_tags" {
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

variable "namespace" {
  type        = string
  description = "Namespace"
}

variable "instance_type" {
  type        = string
  description = "The Instance type that will be used based on the ENV"
}

variable "key_pair_name" {
type        = string
  description = "Key Pair that will be used for the EC2"
}

variable "key_pair_location" {
type        = string
  description = "Key Pair that will be used for the EC2"
}

variable "user_data_location" {
type        = string
  description = "User Data that will be used for the EC2"
}


