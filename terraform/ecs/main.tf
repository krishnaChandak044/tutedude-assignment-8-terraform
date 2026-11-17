data "aws_availability_zones" "available" {

  state = "available"
}
resource "aws_vpc" "app" {
  cidr_block           = "10.55.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-ecs-vpc"
  }
}
resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
}
resource "aws_subnet" "public" {

  count                   = 2
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.55.${count.index + 1}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "${var.project_name}-public-${count.index + 1}"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.app.id
  route {

    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }
}
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_security_group" "alb" {

  name   = "${var.project_name}-alb"
  vpc_id = aws_vpc.app.id
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
resource "aws_security_group" "tasks" {

  name   = "${var.project_name}-tasks"
  vpc_id = aws_vpc.app.id
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_ecr_repository" "flask" {
  name                 = "${var.project_name}-flask"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_repository" "express" {
  name                 = "${var.project_name}-express"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecs_cluster" "app" {
  name = var.project_name
}
resource "aws_iam_role" "execution" {

  name = "${var.project_name}-ecs-execution"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com"
    }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_lb" "app" {
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb.id]
}
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-front"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app.id
  target_type = "ip"
  health_check {

    path    = "/"
    matcher = "200"
  }
}
resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-api"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.app.id
  target_type = "ip"
  health_check {

    path    = "/api/health"
    matcher = "200"
  }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
  condition {

    path_pattern {
      values = ["/api/*"]
    }
  }
}
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 3
}
resource "aws_ecs_task_definition" "flask" {

  family                   = "${var.project_name}-flask"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.execution.arn
  container_definitions = jsonencode([{ name = "flask", image = "${aws_ecr_repository.flask.repository_url}:${var.image_tag}", essential = true, portMappings = [{ containerPort = 5000, protocol = "tcp"
    }], logConfiguration = { logDriver = "awslogs", options = { "awslogs-group" = aws_cloudwatch_log_group.app.name, "awslogs-region" = var.region, "awslogs-stream-prefix" = "flask"
    }
    }
  }])
}
resource "aws_ecs_task_definition" "express" {

  family                   = "${var.project_name}-express"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.execution.arn
  container_definitions = jsonencode([{ name = "express", image = "${aws_ecr_repository.express.repository_url}:${var.image_tag}", essential = true, portMappings = [{ containerPort = 3000, protocol = "tcp"
    }], environment = [{ name = "PORT", value = "3000"
    }, { name = "API_URL", value = "http://${aws_lb.app.dns_name}"
    }], logConfiguration = { logDriver = "awslogs", options = { "awslogs-group" = aws_cloudwatch_log_group.app.name, "awslogs-region" = var.region, "awslogs-stream-prefix" = "express"
    }
    }
  }])
}
resource "aws_ecs_service" "flask" {
  count = var.deploy_services ? 1 : 0

  name            = "${var.project_name}-flask"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.flask.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.tasks.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "flask"
    container_port   = 5000
  }
  depends_on = [aws_lb_listener.http, aws_lb_listener_rule.api, aws_iam_role_policy_attachment.execution]
}
resource "aws_ecs_service" "express" {
  count = var.deploy_services ? 1 : 0

  name            = "${var.project_name}-express"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.express.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.tasks.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "express"
    container_port   = 3000
  }
  depends_on = [aws_lb_listener.http, aws_iam_role_policy_attachment.execution]
}
