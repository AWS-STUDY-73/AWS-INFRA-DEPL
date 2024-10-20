# ============= VPC =======================================
resource "aws_vpc" "MYVPC" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "MYVPC"
  }  
}

resource "aws_subnet" "pubsub1" {
  vpc_id                  = aws_vpc.MYVPC.id
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "pubsub1"
  }
}

resource "aws_subnet" "pubsub2" {
  vpc_id                  = aws_vpc.MYVPC.id
  cidr_block              = "192.168.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1b"
  tags = {
    Name = "pubsub2"
  }
}

resource "aws_route_table" "pubRT" {
  vpc_id = aws_vpc.MYVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "pubRT"
  }
}

resource "aws_route_table_association" "pubRT" {
  subnet_id      = aws_subnet.pubsub1.id
  route_table_id = aws_route_table.pubRT.id
}
resource "aws_route_table_association" "pubRT2" {
  subnet_id      = aws_subnet.pubsub2.id
  route_table_id = aws_route_table.pubRT.id
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.MYVPC.id
  tags = {
    Name = "IGW"
  }
}

# ============= VPC =======================================
# ============= Security Group ============================
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.MYVPC.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2-VPC-ELB_SG"
  }
}

# ============= Security Group ============================
# ============= EC2 =======================================

resource "aws_instance" "web" {
  ami                     = "ami-0522ab6e1ddcc7055"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.pubsub1.id
  vpc_security_group_ids  = [aws_security_group.allow_tls.id]
  key_name                = "ec2-key"
  user_data               = file("userdata.sh")

  tags = {
    Name = "NEW-TEST-SERVER"
  }
}

# ================ EC2 =======================================
# ================ Application Load Balancer =================
resource "aws_lb" "ALB" {
  name               = "ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  
  subnet_mapping {
    subnet_id            = aws_subnet.pubsub1.id
    # private_ipv4_address = "10.0.1.15"
  }

  subnet_mapping {
    subnet_id            = aws_subnet.pubsub2.id
    # private_ipv4_address = "10.0.2.15"
  }

  tags = {
    Name = "ALB"
  }
}

resource "aws_lb_listener" "ALB_LISTENER" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG.arn
  }
}

resource "aws_lb_target_group" "TG" {
  name     = "TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.MYVPC.id
}

resource "aws_lb_target_group_attachment" "TGA" {
  target_group_arn = aws_lb_target_group.TG.arn
  target_id        = aws_instance.web.id
  port             = 80
}

# ============= Application Load Balancer ==========================
# ============= Auto Scaling Group ==========================

resource "aws_launch_configuration" "LC" {
  name          = "LC"
  image_id      = "ami-0522ab6e1ddcc7055"
  instance_type = "t2.micro"
  key_name      = "ec2-key"
  security_groups = [aws_security_group.allow_tls.id]
  user_data = file("userdata.sh")
}

resource "aws_autoscaling_group" "ASG" {
  name                      = "ASG"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  launch_configuration      = aws_launch_configuration.LC.name
  vpc_zone_identifier       = [aws_subnet.pubsub1.id, aws_subnet.pubsub2.id]
  target_group_arns         = [aws_lb_target_group.TG.arn]

  tag {
    key                 = "Name"
    value               = "Launch_By_ASG"
    propagate_at_launch = true
  }
}

# Create a new load balancer attachment
resource "aws_autoscaling_attachment" "ALB_TO_ASG" {
  autoscaling_group_name = aws_autoscaling_group.ASG.id
  elb                    = aws_lb.ALB.id
}

# ============= Auto Scaling Group ==========================
