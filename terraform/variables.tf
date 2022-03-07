variable "ansible-bastion-host" {
  type    = string
  default = "jump.cloudlab.internal"
}
variable "ansible-bastion-user" {
  type = string
}
variable "ansible-identity-files" {
  type    = list(string)
  default = []
}

variable "workers" {
  description = "The number of workers to run"
  type        = number
  default     = 1
  nullable    = false
  validation {
    condition     = var.workers > 0
    error_message = "The number of workers must be a positive integer."
  }
}
