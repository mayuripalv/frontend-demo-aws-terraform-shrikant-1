provider "aws" {
  region = "us-east-1"
}

# First, verify the correct subnet IDs that belong to vpc-03a3ffc65926b8379
# You must use at least two subnets in different Availability Zones
resource "aws_db_subnet_group" "new_db_subnet_group" {
  name        = "new-db-subnet-group"
  description = "New DB subnet group for RDS"
  # Replace these subnet IDs with the ones from your new VPC (vpc-03a3ffc65926b8379)
  subnet_ids  = ["subnet-01732baf7eeae1d72", "subnet-09f79261913ca3bc1"]  # Replace with your actual subnet IDs
}

resource "aws_security_group" "new_rds_sg" {
  name        = "new-emp-rds-sg"
  description = "New security group for RDS MySQL"
  vpc_id      = "vpc-038c604bfe1de28af"

  ingress {
    from_port   = 3306
    to_port     = 3306
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
    Name = "new-emp-rds-sg"
  }
}

resource "aws_db_instance" "new_database" {
  identifier           = "new-emp-rds-db"
  allocated_storage    = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "8.0.40"
  instance_class      = "db.t3.micro"
  db_name             = "employeedb"
  username            = "admin"
  password            = "abc12345"  # Consider using variables
  parameter_group_name = "default.mysql8.0"
  
  db_subnet_group_name   = aws_db_subnet_group.new_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.new_rds_sg.id]
  publicly_accessible    = true
  skip_final_snapshot    = true

  tags = {
    Name = "NewRDSInstance"
  }
}

output "new_rds_endpoint" {
  value = aws_db_instance.new_database.endpoint
}
