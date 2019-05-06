# Create Application Load Balancer
resource "aws_lb" "web" {
  name               = "fabacus-elb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["${aws_subnet.public.id}", "${aws_subnet.public2.id}"]
  security_groups    = ["${aws_security_group.allow_http.id}"]
}

# Create Target Group for Application load balancer
resource "aws_lb_target_group" "web" {
  name       = "web-lb-tg"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = "${aws_vpc.fabacus_vpc.id}"
  depends_on = ["aws_lb.web"]

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200,301,302"
  }
}

# Create Listener for Load Balancer
resource "aws_lb_listener" "web" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web.arn}"
  }
}
