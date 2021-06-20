resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "allow_ssh" {
    name        = "tf-sg-nv"
    description = "allow ports for nginx demo"
    vpc_id      =  aws_default_vpc.default.id

# to allow traffic from outside to inside
    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

# to allow traffic from inside to outside i.e.from instance to internet
    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# in this block we are actually defining out instance which will be nginx with t2.micro as resource type
   resource "aws_instance" "nginx" {
       ami                     = data.aws_ami.aws-linux.id
       instance_type           = "t2.micro"
       key_name                = var.key_name
       vpc_security_group_ids  = [aws_security_group.allow_ssh.id]

# since we are doing SSH so we need to define a connection in resource block, so that terraform understand where to connect
    connection {
            type        = "ssh"
            host        = self.public_ip
            user        = "ec2-user"
            private_key = file(var.private_key_path)
        }

# since we want to remotely exec command so
    provisioner    "remote-exec" {
        inline = [
            "sudo yum install nginx -y" ,
            "sudo service nginx start"
        ]
    }
}
