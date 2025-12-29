output "flask_ecr_url" {
  value = aws_ecr_repository.flask_backend.repository_url
}

output "express_ecr_url" {
  value = aws_ecr_repository.express_frontend.repository_url
}

# ————————————————
# Add this block below
output "alb_dns" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.part3_alb.dns_name
}
