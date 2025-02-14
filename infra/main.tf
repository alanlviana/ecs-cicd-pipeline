


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

resource "aws_security_group" "example" {
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