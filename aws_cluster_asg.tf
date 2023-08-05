# configuration for creating a cluster of instances under auto scaling group

# specify the launch config for each instance to be created in the asg cluster
# lifecycle is very important as without it terraform wont be able to update launch_configs for cluster
resource "aws_launch_configuration" "instance" {
  image_id        = "ami-0fb653ca2d3203ac1"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

# write config for asg group specifying details like min, max instances, etc.
resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.instance.name
  vpc_zone_identifier  = data.aws_subnets.subnet_data.ids
  min_size             = 2
  max_size             = 4

  tag {
    key                 = "Name"
    value               = "asg-cluster-instance"
    propagate_at_launch = true
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

# add data source to get data from aws about certain resources
data "aws_vpc" "vpc_data" {
  default = true
}

# data source to get subnets data from a given vpc id
data "aws_subnets" "subnet_data" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_data.id]
  }
}
