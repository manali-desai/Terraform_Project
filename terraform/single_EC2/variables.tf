# Key for Flask backend
variable "flask_key_name" {
  description = "Name of the SSH key pair for the Flask backend EC2"
  type        = string
}

# Key for Express frontend
variable "express_key_name" {
  description = "Name of the SSH key pair for the Express frontend EC2"
  type        = string
}
