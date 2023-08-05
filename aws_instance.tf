# configuration to launch a simple aws instance and run a busybox server in it

# first step is to configure the provider. Take AWs for this example
provider "aws" {
  region = "us-east-2"
}

# next step is to create a resource
resource "aws_instance" "instance_1" {
  ami                         = "ami-0fb653ca2d3203ac1"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.sgi-1.id]
  user_data                   = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  user_data_replace_on_change = true
  tags = {
    name = "Instance-1"
  }
}

# to avoid repetitions, create a variable called server_port
variable "server_port" {
  description = "This port will be opened in the instance for everyone to access"
  type        = number
  default     = 8080
  # a varible can be set using many other forms like -var, env as TF_VAR <name>,
  # if nothing is set this default will be used
}

# create a security group with port 8080 open
resource "aws_security_group" "sgi-1" {
  name = "terraform-sg"
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# instead of going to aws console for ip, print in terminal using output
output "public_ip" {
  value       = aws_instance.instance_1.public_ip
  description = "The public IP address of the web server"
}
