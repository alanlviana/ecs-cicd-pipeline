resource "aws_iam_role" "ecs_task_execution_role" {
    name = "${var.app_name}-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
    role       = aws_iam_role.ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "app_sg" {
    name        = "${var.app_name}-sg"
    description = "Allow HTTP inbound traffic"
    vpc_id      = aws_vpc.vpc_ecs.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [ aws_security_group.lb_sg.id ]
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        security_groups = [ aws_security_group.lb_sg.id ]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "lb_sg" {
    name        = "${var.app_name}-lb-sg"
    description = "Allow HTTP inbound traffic"
    vpc_id      = aws_vpc.vpc_ecs.id

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
