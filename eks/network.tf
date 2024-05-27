# Create internal load balancer

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = true
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.private : subnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "example" {
  count = 2
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = module.eks.node_groups["eks_nodes"].instances[count.index].id
  port             = 80
}

# Route Table
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "private-route-table"
        }
        route {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_nat_gateway.nat.id
        }
}

# Route Table Association

resource "aws_route_table_association" "private" {
    subnet_id = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
    count =1

}