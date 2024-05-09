provider "aws" {
 region = "us-east-1"
 shared_config_files=["./aws/config"]
 shared_credentials_files=["./aws/config"]
}

resource "aws_instance" "ec2_instance-1" {
  ami           = "ami-04ff98ccbfa41c9ad"
  instance_type = "t2.micro"
  subnet_id     = "subnet-029ee61487163fa02" # ID da Subnet
  vpc_security_group_ids = ["${aws_security_group.instance_sg.id}"]

  key_name = "vockey"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              sudo apt install cifs-utils -y
              sudo apt install nfs-common -y
              sudo mkdir /mnt/efs
              cd /mnt
              sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-00437f50f7231531e.efs.us-east-1.amazonaws.com:/ efs
              EOF

  tags = {
    Name = "EC2_Instance-1"
  }
}

resource "aws_instance" "ec2_instance-2" {
  ami           = "ami-04ff98ccbfa41c9ad"
  instance_type = "t2.micro"
  subnet_id     = "subnet-029ee61487163fa02" # ID da Subnet
  vpc_security_group_ids = ["${aws_security_group.instance_sg.id}"]

  key_name = "vockey"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              sudo mkdir /mnt/efs
              sudo cd /mnt/efs
              sudo mount -t efs -o tls fs-0d5a3daa8e7d13dcf.efs.us-east-1.amazonaws.com /mnt/efs
              EOF

  tags = {
    Name = "EC2_Instance-2"
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "grupo-seguranca-linux-1"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = "vpc-0e37f675c40100eec"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "github_sha" {}

output "public_ip-1" {
  value = aws_instance.ec2_instance-1.public_ip
}
output "public_ip-2" {
  value = aws_instance.ec2_instance-2.public_ip
}
