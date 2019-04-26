# AWS credentials are stored in the file ~/.aws/credentials 

provider "aws" {
    region                  =   "${var.region}"
}


# Create a VPC to launch ECS into
resource "aws_vpc" "fabacus_vpc" {
    cidr_block              =   "${var.vpc_cidr_block}"
    enable_dns_hostnames    =   "True"   
    instance_tenancy        =   "default"
    tags                    =   {
        Name                =   "Fabacus_VPC"
        Project             =   "fabacus"
    }
}

# Create network ACL for VPC, allow INBOUND ports 80 and 443,  allow ALL OUTBOUND traffic
resource "aws_network_acl" "main" {
    vpc_id                  =   "${aws_vpc.fabacus_vpc.id}"
    subnet_ids              =   ["${aws_subnet.private.id}", "${aws_subnet.public.id}"]
    
    egress {
        protocol            =   "tcp"
        rule_no             =   200
        action              =   "allow"
        cidr_block          =   "0.0.0.0/0"
        protocol            =   "all"
        from_port           =   "0"
        to_port             =   "0"
    }
    
    ingress {
        protocol            =   "tcp"
        rule_no             =   100
        action              =   "allow"
        cidr_block          =   "0.0.0.0/0"
        from_port           =   "80"
        to_port             =   "80"
    }
    ingress {
        protocol            =   "tcp"
        rule_no             =   105
        action              =   "allow"
        cidr_block          =   "0.0.0.0/0"
        from_port           =   "443"
        to_port             =   "443"
    }
    tags = {
    Name = "main_ACL"
    }
}

# Create VPC Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id                  =   "${aws_vpc.fabacus_vpc.id}"
    tags = {
    Name = "fabacus_igw"
    }
}

# Create public subnet for VPC
resource "aws_subnet" "public" {
    vpc_id                  =   "${aws_vpc.fabacus_vpc.id}"
    cidr_block              =   "${var.vpc_subnet["public"]}"
    availability_zone       =   "${var.region}a"
    
    tags = {
    Name = "fabacus_public_subnet"
    }
}

resource "aws_subnet" "public2" {
    vpc_id                  =   "${aws_vpc.fabacus_vpc.id}"
    cidr_block              =   "${var.vpc_subnet["public2"]}"
    availability_zone       =   "${var.region}b"

    tags = {
    Name = "fabacus_public2_subnet"
    }
}

# Create private subnet for VPC
resource "aws_subnet" "private" {
    vpc_id                  =   "${aws_vpc.fabacus_vpc.id}"
    cidr_block              =   "${var.vpc_subnet["private"]}"
    availability_zone       =   "${var.region}a"
    tags = {
    Name = "fabacus_private_subnet"
    }
}

resource "aws_subnet" "private2" {
    vpc_id                  =   "${aws_vpc.fabacus_vpc.id}"
    cidr_block              =   "${var.vpc_subnet["private2"]}"
    availability_zone       =   "${var.region}b"
    tags = {
    Name = "fabacus_private2_subnet"
    }
}


# Create Route table for public subnet
resource "aws_route_table" "pub_rt" {
    vpc_id                    =   "${aws_vpc.fabacus_vpc.id}"
    tags = {
        Name                    = "fabacus_public_rt"
    }
}

# Create Route table for private subnet
resource "aws_route_table" "priv_rt" {
    vpc_id                    =   "${aws_vpc.fabacus_vpc.id}"
    tags = {
        Name                    = "fabacus_private_rt"
    }
}

# Create route for public route table
resource "aws_route" "pub_route" {
    route_table_id            =   "${aws_route_table.pub_rt.id}"
    destination_cidr_block    =   "0.0.0.0/0"
    gateway_id                =   "${aws_internet_gateway.igw.id}"
    depends_on                =   ["aws_route_table.pub_rt"]
}


# Create an association between a public subnet and public routing table
resource "aws_route_table_association" "public_assoc" {
    subnet_id                 =   "${aws_subnet.public.id}"
    route_table_id            =   "${aws_route_table.pub_rt.id}"
}

resource "aws_route_table_association" "public2_assoc" {
    subnet_id                 =   "${aws_subnet.public2.id}"
    route_table_id            =   "${aws_route_table.pub_rt.id}"
}

# Create an association between a private subnet and private routing table
resource "aws_route_table_association" "private_assoc" {
    subnet_id                 =   "${aws_subnet.private.id}"
    route_table_id            =   "${aws_route_table.priv_rt.id}"
}

resource "aws_route_table_association" "private2_assoc" {
    subnet_id                 =   "${aws_subnet.private2.id}"
    route_table_id            =   "${aws_route_table.priv_rt.id}"
}

# Create security_group for VPC
resource "aws_security_group" "allow_http" {
    vpc_id                    =   "${aws_vpc.fabacus_vpc.id}"
    name                      =   "allow_http"
    description               =   "Allow HTTP/HTTPS inbound traffic"

    ingress {
        from_port               =   443
        to_port                 =   443
        protocol                =   "tcp"
        cidr_blocks             =   ["0.0.0.0/0"]
    }
  
    ingress {
        from_port               =   80
        to_port                 =   80
        protocol                =   "tcp"
        cidr_blocks             =   ["0.0.0.0/0"]
    }
    
    egress {
        from_port               =   0
        to_port                 =   0
        protocol                =   "-1"
        cidr_blocks             =   ["0.0.0.0/0"]
    }

    tags = {
        Name                    = "allow_http"
    }
}


# Create Application Load Balancer
resource "aws_lb" "web" {
    name                    =   "fabacus-elb"
    internal                =   false
    load_balancer_type      =   "application"
    subnets                 =   ["${aws_subnet.public.id}", "${aws_subnet.public2.id}"]
    security_groups         =   ["${aws_security_group.allow_http.id}"]

}

# Create Target Group for Application load balancer
resource "aws_lb_target_group" "web" {
    name                    =   "web-lb-tg"
    port                    =   80
    protocol                =   "HTTP"
    vpc_id                  =   "${aws_vpc.fabacus_vpc.id}"
    
    health_check {
        interval                =   10
    }
}

# Create Listener for Load Balancer
resource "aws_lb_listener" "web" {
    load_balancer_arn       =   "${aws_lb.web.arn}"
    port                    =   "80"
    protocol                =   "HTTP"
    
    default_action {
        type                    =   "forward"
        target_group_arn        =   "${aws_lb_target_group.web.arn}"
    }
}


# Create ECS cluster
resource "aws_ecs_cluster" "fabacus" {
    name                    =   "Fabacus"
}


# Create Role for EC2 instance_tenancy

resource "aws_iam_role" "ecsInstanceRole" {
    name                    =   "test_role"
    assume_role_policy      =   <<EOF
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


data "aws_iam_policy" "ecs_policy" {
    arn                     =   "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecsInstanceRole" {
    role                    =   "${aws_iam_role.ecsInstanceRole.name}"
    policy_arn              =   "${data.aws_iam_policy.ecs_policy.arn}"
}





# Create task definition
resource "aws_ecs_task_definition" "service" {
    family                  =   "nginx"
    container_definitions   =   "${file("./service.json")}"
    network_mode            =   "bridge"
}


resource "aws_ecs_service" "nginx" {
    name                    =   "nginx"
    cluster                 =   "${aws_ecs_cluster.fabacus.id}"
    task_definition         =   "${aws_ecs_task_definition.service.arn}"
    desired_count           =   1


    load_balancer {
        target_group_arn    =   "${aws_lb_target_group.web.arn}"
        container_name      =   "nginxdemos"
        container_port      =   80
    }

    network_configuration {
        subnets             =   ["${aws_subnet.public.id}", "${aws_subnet.public2.id}", "${aws_subnet.private.id}", "${aws_subnet.private2.id}"]
        security_groups     =   ["${aws_security_group.allow_http.id}"]
    }
}