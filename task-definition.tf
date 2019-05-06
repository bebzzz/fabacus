# Create task definition
resource "aws_ecs_task_definition" "service" {
  family = "nginx"

  #network_mode             =  "bridge"
  requires_compatibilities = ["EC2"]
  container_definitions    = "${file("./service.json")}"
}
