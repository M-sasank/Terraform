# first step is to configure the provider. Take AWs for this example
provider "aws" {
  region = "us-east-2"
}

# next step is to create a resource
resource "aws_instance" "instance_1" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  tags = {
    name = "Instance-1"
  }
}
