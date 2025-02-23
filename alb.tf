# Data source for existing VPC
data "aws_vpc" "existing_vpc" {
  id = var.existing_vpc_id  # This will use the VPC ID from terraform.tfvars
}

# Data source for existing subnets
data "aws_subnet" "existing_subnets" {
  count = length(var.existing_subnet_ids)
  id    = var.existing_subnet_ids[count.index]  # This will use the subnet IDs from terraform.tfvars
}

# Create Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.existing_vpc.id  # This automatically uses your VPC ID

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-security-group"
  }
}

# Create Application Load Balancer
resource "aws_lb" "application_lb" {
  name               = "my-application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.existing_subnet_ids  # This automatically uses your subnet IDs

  enable_deletion_protection = false

  tags = {
    Environment = "production"
    Name        = "my-alb"
  }
}

# Create Target Group
resource "aws_lb_target_group" "target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.existing_vpc.id  # This automatically uses your VPC ID

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval           = 30
    matcher            = "200"
    path               = "/"
    port               = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "my-target-group"
  }
}

# Create Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Variables definition
variable "existing_vpc_id" {
  description = "ID of existing VPC"
  type        = string
}

variable "existing_subnet_ids" {
  description = "List of existing subnet IDs"
  type        = list(string)
}

# Outputs
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.application_lb.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.target_group.arn
}