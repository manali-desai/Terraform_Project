# Outputs for Flask backend
output "flask_instance_id" {
  value       = aws_instance.flask_instance.id
  description = "ID of the Flask backend EC2 instance"
}

output "flask_public_ip" {
  value       = aws_instance.flask_instance.public_ip
  description = "Public IP of the Flask backend EC2 instance"
}

# Outputs for Express frontend
output "express_instance_id" {
  value       = aws_instance.express_instance.id
  description = "ID of the Express frontend EC2 instance"
}

output "express_public_ip" {
  value       = aws_instance.express_instance.public_ip
  description = "Public IP of the Express frontend EC2 instance"
}
