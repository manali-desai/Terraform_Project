# Terraform Deployment of Flask & Express Applications

## Project Overview
This project deploys a **Flask backend** and an **Express frontend** on AWS using Terraform.  
It demonstrates three deployment approaches:

1. **Single EC2 Instance**: Both apps running on one EC2 instance.
2. **Separate EC2 Instances**: Flask and Express on different EC2 instances.
3. **Dockerized Deployment (Documentation Only)**: Apps containerized using Docker, pushed to AWS ECR, and deployable via ECS and ALB.

---

## Architecture

### Part 1: Single EC2
- EC2 instance running both Flask and Express
- Flask backend: port **5000**
- Express frontend: port **3000**

### Part 2: Separate EC2 Instances
- Flask EC2 → backend
- Express EC2 → frontend
- Security groups allow communication between instances
- Public access to respective ports

### Part 3: Dockerized ECS Deployment (Documentation)
- Flask and Express containerized using Docker
- Images pushed to AWS ECR
- Deployable on ECS Fargate services
- ALB routes traffic to the respective service

> Note: Dockerization and ECS deployment are documented for clarity; actual deployment was not performed.

---

## Pre-requisites
- AWS account with necessary permissions
- Terraform installed
- Git installed
- AWS CLI configured with credentials
- Docker installed (for Part 3 documentation)

---

## Deployment Steps

### Part 1 & Part 2: EC2 Deployment
```bash
# Navigate to project folder
cd terraform_project

# Initialize Terraform
terraform init

# Preview the plan
terraform plan

# Apply the infrastructure
terraform apply

# Check outputs
terraform output
