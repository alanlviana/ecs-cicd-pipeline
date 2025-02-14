


resource "aws_ecs_cluster" "example" {
    name = var.cluster_name
}

resource "aws_ecs_service" "example" {
    name            = var.app_name
    cluster         = aws_ecs_cluster.example.id
    task_definition = aws_ecs_task_definition.example.arn
    desired_count   = 1
    launch_type     = "FARGATE"
    network_configuration {
        subnets         = var.subnet_ids
        security_groups = [aws_security_group.example.id]
    }
    load_balancer {
        target_group_arn = aws_lb_target_group.app_tg.arn
        container_name   = var.app_name
        container_port   = 80
    }

    depends_on = [aws_lb_listener.app_listener]
}

resource "aws_ecs_task_definition" "example" {
    family                   = var.app_name
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = "256"
    memory                   = "512"
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

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
            ]
        }
    ])
}

resource "aws_security_group" "app_sg" {
    name        = "${var.app_name}-sg"
    description = "Allow HTTP inbound traffic"
    vpc_id      = var.vpc_id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_lb" "app_lb" {
  name               = "${var.app_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.app_name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}