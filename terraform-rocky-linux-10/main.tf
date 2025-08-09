provider "aws" {
  region = "us-east-1" # Change as needed
}

resource "aws_instance" "test_ec2" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI for us-east-1
  instance_type = "t2.micro"
  key_name      = "your-keypair-name" # Replace with your actual key pair name

  tags = {
    Name = "TestEC2Instance"
  }
}
