resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = "${aws_ecs_cluster.fabacus.id}"
  task_definition = "${aws_ecs_task_definition.service.arn}"
  desired_count   = 2

  #iam_role                =   "${aws_iam_role.ecs-service-role.arn}"
  depends_on = ["aws_iam_role_policy.ecs-ec2-role-policy"]

  load_balancer {
    target_group_arn = "${aws_lb_target_group.web.arn}"
    container_name   = "nginxdemos"
    container_port   = 80
  }

  # network_configuration {
  #     subnets             =   ["${aws_subnet.public.id}", "${aws_subnet.public2.id}", "${aws_subnet.private.id}", "${aws_subnet.private2.id}"]
  #     security_groups     =   ["${aws_security_group.allow_http.id}"]
  # }
}
