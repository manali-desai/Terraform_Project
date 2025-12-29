resource "aws_ecr_repository" "flask_backend" {
  name = "flask-backend-part3"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "express_frontend" {
  name = "express-frontend-part3"

  image_scanning_configuration {
    scan_on_push = true
  }
}
