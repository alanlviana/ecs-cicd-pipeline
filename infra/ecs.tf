


resource "aws_ecs_cluster" "app_cluster" {
    name = var.cluster_name
}

resource "aws_ecs_service" "app_service" {
    name            = var.app_name
    cluster         = aws_ecs_cluster.app_cluster.id
    task_definition = aws_ecs_task_definition.app_task_definition.arn
    desired_count   = 1
    launch_type     = "FARGATE"
    network_configuration {
        subnets         = aws_subnet.public_subnets[*].id
        security_groups = [aws_security_group.app_sg.id]
    }
    load_balancer {
        target_group_arn = aws_lb_target_group.app_tg.arn
        container_name   = var.app_name
        container_port   = 80
    }

    depends_on = [aws_lb_listener.app_listener]
}

resource "aws_ecs_task_definition" "app_task_definition" {
    family                   = var.app_name
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = "256"
    memory                   = "512"
    execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

    container_definitions = jsonencode([
        {
            name      = var.app_name
            image     = var.image
            essential = true
            portMappings = [
                {
                    containerPort = 80
                    hostPort      = 80
                }
            ],
            environment = var.container_environment_variables,
            healthCheck = {
                retries = 10
                command = [ "CMD-SHELL", "curl -f http://localhost:80 || exit 1" ]
                timeout = 5
                interval = 10
                startPeriod = 10
            }
        }
    ])
}



resource "aws_lb" "app_lb" {
  name               = "${var.app_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.app_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc_ecs.id
  target_type = "ip"
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}