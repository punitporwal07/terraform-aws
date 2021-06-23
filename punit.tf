#PROVIDER
provider "aws" {
  region = "us-east-1"
}


#VARIABLE
variable "aws_access_key" { default = "value" }
variable "aws_secret_key" { default = "value" }
variable "key_name" { default = "ec2-kp-nv" }
variable "public_key" { default = "/home/ec2-user/stuff/ec2-kp-nv.pub" }
variable "region" { default = "us-east-1" }


#DATA
data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


#RESOURCE
resource "aws_key_pair" "tf-kp" {
  key_name   = "tf-kp"
  public_key = file("/home/ec2-user/stuff/ec2-kp-nv.pub")
}

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "allow_ssh" {
  name        = "tf-sg-nv"
  description = "allow ports for nginx demo"
  vpc_id      = aws_default_vpc.default.id

  # to allow traffic from outside to inside
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # to allow traffic from inside to outside i.e.
  #  from instance to internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# in this block we are actually defining out instance which will be nginx with t2.micro as resource type
resource "aws_instance" "nginx" {
  ami           = data.aws_ami.aws-linux.id
  instance_type = "t2.micro"
  #  key_name               = var.key_name
  key_name               = "ec2-kp-nv"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  # since we are doing SSH so we need to define a connection in resource block, so that terraform understand where to connect
  connection {
    type        = "ssh"
    host        = self.public_ip
    host_key    = file("/home/ec2-user/stuff/ec2-kp-nv.pub")
    user        = "ec2-user"
    private_key = file("/home/ec2-user/stuff/ec2-kp-nv.pem")
  }

  # since we want to remotely exec command so
  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start"
    ]
  }
}

#OUTPUT
output "aws_instance_public_dns" {
  value = aws_instance.nginx.public_dns
}
