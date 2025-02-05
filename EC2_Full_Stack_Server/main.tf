provider "aws" {
  region = "us-east-1" # replace with your_preferred_region
}

# Create EC2 instance
resource "aws_instance" "Full_Stack_Server" {
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = "t2.micro"
  key_name               = "ec2-key-shrikant"
  vpc_security_group_ids = ["sg-0fc49a74d859ad72f"]
}

output "ssh_command" {
  value = "ssh -i /home/lili/ec2-key-shrikant.pem ubuntu@${aws_instance.Full_Stack_Server.public_ip}"
}