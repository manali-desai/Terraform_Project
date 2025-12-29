# -------------------------
# Default VPC
# -------------------------
data "aws_vpc" "default" {
  default = true
}

# -------------------------
# Latest Ubuntu 22.04 LTS AMI
# -------------------------
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

# -------------------------
# Security Group
# -------------------------
resource "aws_security_group" "flask_express_sg" {
  name        = "flask-express-sg"
  description = "Allow SSH, Flask (5000), Express (3000)"
  vpc_id      = data.aws_vpc.default.id

  # SSH for both instances
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask backend port
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Express frontend port
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# Flask Backend EC2
# -------------------------
resource "aws_instance" "flask_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = var.flask_key_name
  vpc_security_group_ids = [aws_security_group.flask_express_sg.id]

  tags = {
    Name = "flask-backend"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y python3 python3-pip git curl
    sudo pip3 install flask

    mkdir -p /home/ubuntu/flask_app
    cat <<EOT > /home/ubuntu/flask_app/app.py
from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Backend is running Successfully."

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
EOT

    nohup python3 /home/ubuntu/flask_app/app.py > /home/ubuntu/flask_app/nohup.out 2>&1 &
EOF
}

# -------------------------
# Express Frontend EC2
# -------------------------
resource "aws_instance" "express_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = var.express_key_name
  vpc_security_group_ids = [aws_security_group.flask_express_sg.id]

  tags = {
    Name = "express-frontend"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y curl git
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs

    mkdir -p /home/ubuntu/express_app
    cd /home/ubuntu/express_app
    npm init -y
    npm install express

    cat <<EOT > /home/ubuntu/express_app/server.js
const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => res.send("Hello from frontend!"));
app.listen(PORT, () => console.log("Express running on port " + PORT));
EOT

    nohup node /home/ubuntu/express_app/server.js > /home/ubuntu/express_app/nohup.out 2>&1 &
EOF
}

# -------------------------
# Outputs
# -------------------------
output "flask_instance_public_ip" {
  value = aws_instance.flask_instance.public_ip
}

output "express_instance_public_ip" {
  value = aws_instance.express_instance.public_ip
}
