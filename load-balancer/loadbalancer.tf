resource "aws_lb" "verteiler" {
  name               = "TF-LoadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.server_sgs.id]
  subnets            = [for subnet in aws_subnet.publics : subnet.id]

   enable_deletion_protection = false 
}

resource "aws_lb_target_group" "zielgruppe" {
  name     = "tf-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mynet.id
}

resource "aws_lb_target_group_attachment" "anhang" {
  count            = length(aws_instance.servers)
  target_group_arn = aws_lb_target_group.zielgruppe.arn
  target_id        = aws_instance.servers[count.index].id
  port             = 80
}

resource "aws_lb_listener" "ohren" {
  load_balancer_arn = aws_lb.verteiler.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
        target_group {
            arn = aws_lb_target_group.zielgruppe.arn
        }
    }
  }
}