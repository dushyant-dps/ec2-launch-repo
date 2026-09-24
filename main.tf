data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
resource "aws_security_group" "ec2" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Terraform EC2"
  vpc_id      = data.aws_vpc.default.id
  # No inbound access by default.
  # Add only the ports you actually need.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.instance_name}-sg"
  }
}
resource "aws_instance" "ec2" {
  ami           = data.aws_ssm_parameter.amazon_linux.value
  instance_type = var.instance_type
  subnet_id = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]
  tags = {
    Name = var.instance_name
  }
}