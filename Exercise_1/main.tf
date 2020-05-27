# TODO: Designate a cloud provider, region, and credentials

# configure AWS provider, version is optional but recommended to use, shared credentials preconfigured via AWS CLI in .aws\credentials will be used -> no explicit credentials cfg required
provider "aws" {
  version   = "~> 2.0"
  region    = "eu-central-1" # Frankfurt EU Region
}
###########
### VPC ###
###########

# Create a VPC
resource "aws_vpc" "udacity-vpc" {
  cidr_block    = "10.0.0.0/16"

  tags = {
        Name="udacity-vpc"
    }
}

# Create a Subnet

resource "aws_subnet" "udacity-public-subnet" {
    vpc_id      = aws_vpc.udacity-vpc.id
    cidr_block  = "10.0.0.0/24"

    tags = {
        Name = "udacity-public-subnet"
    }
}


###########
### EC2 ###
###########

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "t2micro" {
  count         = "4"
  ami           = "ami-076431be05aaf8080" # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.udacity-public-subnet.id # reference to public subnet, machines will be deployed here

  tags = {
    Name  = "Udacity T2-${count.index + 1}"
  }
}

