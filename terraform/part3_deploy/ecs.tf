# ECS Cluster
resource "aws_ecs_cluster" "part3_cluster" {
  name = "part3-cluster"
}

# ECS Task Definition for Flask Backend
resource "aws_ecs_task_definition" "flask_task" {
  family                   = "flask-backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "flask-backend"
      image     = "596596146200.dkr.ecr.ap-south-1.amazonaws.com/flask-backend-part3:latest"
      essential = true

      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# ECS Task Definition for Express Frontend
resource "aws_ecs_task_definition" "express_task" {
  family                   = "express-frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "express-frontend"
      image     = "596596146200.dkr.ecr.ap-south-1.amazonaws.com/express-frontend-part3:latest"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# ECS Service for Flask Backend
resource "aws_ecs_service" "flask_service" {
  name            = "flask-backend-service"
  cluster         = aws_ecs_cluster.part3_cluster.id
  task_definition = aws_ecs_task_definition.flask_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.flask_tg.arn
    container_name   = "flask-backend"
    container_port   = 5000
  }
}

# ECS Service for Express Frontend
resource "aws_ecs_service" "express_service" {
  name            = "express-frontend-service"
  cluster         = aws_ecs_cluster.part3_cluster.id
  task_definition = aws_ecs_task_definition.express_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.public_1.id, aws_subnet.public_2.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.express_tg.arn
    container_name   = "express-frontend"
    container_port   = 3000
  }
}
