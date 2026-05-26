variable "onid" {
  description = "Your unique ONID identifier for resource tagging"
  type        = string
}

variable "key_name" {
  description = "The name of your AWS EC2 SSH key pair"
  type        = string
}

variable "instance_type" {
  description = "The size of the EC2 instance running k3s"
  type        = string
  default     = "t3.medium" 
}

variable "my_ip" {
  description = "My current local public IP address for secure SSH access"
  type        = string
}