output "instance_public_ip" {
  description = "Public IP of the test EC2 instance"
  value       = aws_instance.test_ec2.public_ip
}
