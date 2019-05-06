# Create ECS cluster
resource "aws_ecs_cluster" "fabacus" {
    name                    =   "fabacus"
}


#Compute
resource "aws_autoscaling_group" "fabacus-cluster" {
  name                      = "fabacus-cluster"
  vpc_zone_identifier       = ["${aws_subnet.private.id}", "${aws_subnet.private2.id}"]
  min_size                  = "2"
  max_size                  = "10"
  desired_capacity          = "2"
  launch_configuration      = "${aws_launch_configuration.cluster-lc.name}"
  health_check_grace_period = 120
  default_cooldown          = 30
  termination_policies      = ["OldestInstance"]

  tag {
    key                     =   "Name"
    value                   =   "ECS-fabacus"
    propagate_at_launch     =   true
  }
}

resource "aws_autoscaling_policy" "fabacus-cluster" {
  name                      = "fabacus-ecs-auto-scaling"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = "90"
  adjustment_type           = "ChangeInCapacity"
  autoscaling_group_name    = "${aws_autoscaling_group.fabacus-cluster.name}"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 80.0
  }
}


# User data for ECS cluster
data "template_file" "ecs-cluster" {
  template                  =   "${file("ecs-cluster.tpl")}"

  vars {
    ecs_cluster             =   "${aws_ecs_cluster.fabacus.name}"
  }
}

resource "aws_launch_configuration" "cluster-lc" {
  name_prefix     = "fabacus-cluster-lc"
  security_groups = ["${aws_security_group.allow_http.id}"]

  #key_name                    = "bebz"
  image_id                    = "${var.images["${var.region}"]}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs-ec2-role.id}"
  user_data                   = "${data.template_file.ecs-cluster.rendered}"
  associate_public_ip_address = false

  lifecycle {
    create_before_destroy = true
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name    =   "${aws_autoscaling_group.fabacus-cluster.id}"
  alb_target_group_arn      =   "${aws_lb_target_group.web.arn}"
  depends_on                =   ["aws_launch_configuration.cluster-lc", "aws_autoscaling_group.fabacus-cluster"]
}
