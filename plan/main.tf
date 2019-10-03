provider "aws" {
    region = "us-east-1"
    version = "~> 2.25"
}

data "aws_availability_zones" "available" {}

# Random Id

resource "random_id" "bucket_id" {
  keepers = {
    vpc_id = "${aws_vpc.vpc.id}"
  }

  byte_length = 8
}

# VPC

resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
}

# Internet gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

# IAM Role, Profile

resource "aws_iam_role" "s3_access_role" {
  name = "s3_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
  {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
  },
      "Effect": "Allow",
      "Sid": ""
      }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access_profile"
  role = "${aws_iam_role.s3_access_role.name}"
}

# IAM S3 Access Policy

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3_access_policy"
  role = "${aws_iam_role.s3_access_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

# Route tables

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }

  tags = {
    Name = "public"
  }
}

# Subnets

resource "aws_subnet" "public1" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.cidrs["public1"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "public1"
  }
}

# Subnet Associations

resource "aws_route_table_association" "public1_assoc" {
  subnet_id      = "${aws_subnet.public1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

#Security groups

resource "aws_security_group" "dev_sg" {
  name        = "dev_sg"
  description = "Used for ssh, http access to the node server"
  vpc_id      = "${aws_vpc.vpc.id}"

  #SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}/32"]
  }

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public_sg" {
  name        = "sg_public"
  vpc_id      = "${aws_vpc.vpc.id}"

  #SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}/32"]
  }

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outbound internet access

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# key pair

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

# server

resource "aws_s3_bucket" "bucket" {
  bucket = "aws-terraform-node-server-${random_id.bucket_id.hex}"
  acl    = "private"

  tags = {
    Name = "Server Source Code"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "server.zip"
  source = "./temp/server.zip"
  etag = "${filemd5("./temp/server.zip")}"
}

resource "aws_instance" "dev" {
  instance_type = "${var.dev_instance_type}"
  ami           = "${var.dev_ami}"
  user_data            = <<EOF
#!/bin/bash
apt update -y
apt install python nodejs npm unzip -y
curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
aws s3 cp s3://aws-terraform-node-server-${random_id.bucket_id.hex}/server.zip ./
unzip ./server.zip
cd ./server
chmod +x ./index.js
npm install
echo "[Unit]" > /etc/systemd/system/node_server.service
echo "Description=Node Server [Service]" >> /etc/systemd/system/node_server.service
echo "[Service]" >> /etc/systemd/system/node_server.service
cwd=$(pwd) && echo "ExecStart=$cwd/index.js" >> /etc/systemd/system/node_server.service
echo "Restart=always" >> /etc/systemd/system/node_server.service
echo "KillSignal=SIGQUIT" >> /etc/systemd/system/node_server.service
cwd=$(pwd) && echo "WorkingDirectory=$cwd" >> /etc/systemd/system/node_server.service
echo "[Install]" >> /etc/systemd/system/node_server.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/node_server.service
systemctl enable node_server.service
systemctl start node_server.service
EOF

  iam_instance_profile   = "${aws_iam_instance_profile.s3_access_profile.id}"

  tags = {
    Name = "nodejs-instance"
  }

  key_name               = "${aws_key_pair.auth.id}"
  vpc_security_group_ids = ["${aws_security_group.public_sg.id}"]
  subnet_id              = "${aws_subnet.public1.id}"

}

#-------OUTPUTS ------------

output "NodeServerAddress" {
  value = "http://${aws_instance.dev.public_ip}:80"
}
