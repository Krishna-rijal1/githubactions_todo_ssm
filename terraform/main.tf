
//creating vpc
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
}

//creating public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-1a"
}


//creating internet gateway
resource "aws_internet_gateway" "my_internet_gwy" {
  vpc_id = aws_vpc.my_vpc.id
}


//creating route table for public
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_internet_gwy.id
  }
}
//subnet association
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id

}


//creating security groups
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id
  //Inbound rule for SSH (for instance in the private subnet)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  //Inbound rule for HTTP traffic (for instance in the public subnet)
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "ansible_conf" {
  ami             = "ami-0c7217cdde317cfec"
  instance_type   = "t2.micro"
  associate_public_ip_address = true
  subnet_id       = aws_subnet.public_subnet.id
  key_name        = "krishna"
  security_groups = [aws_security_group.my_security_group.id]
     iam_instance_profile        = aws_iam_instance_profile.ssm_ec2.name
  volume_tags = local.tags
  tags = {
    Name = "115_ansible_server"
  }
  
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

}

resource "aws_iam_role" "ssm" {
  name = "test_ssm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

}


data "aws_iam_policy" "aws_managed_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment_1" {
  role       = aws_iam_role.ssm.name
  policy_arn = data.aws_iam_policy.aws_managed_policy.arn
}
resource "aws_iam_instance_profile" "ssm_ec2" {
  name = "ec2_role_ssm"
  role = aws_iam_role.ssm.name
}
