terraform { required_version=">= 1.5.0"; required_providers { aws={source="hashicorp/aws",version="~> 5.0"} } }
provider "aws" { region=var.region }
resource "aws_vpc" "app" { cidr_block="10.55.0.0/16"; enable_dns_hostnames=true; tags={Name="tutedude-ecs-vpc"} }
resource "aws_subnet" "public" { count=2; vpc_id=aws_vpc.app.id; cidr_block="10.55.${count.index+1}.0/24"; map_public_ip_on_launch=true; availability_zone="${var.region}${count.index==0 ? "a" : "b"}" }
resource "aws_internet_gateway" "app" { vpc_id=aws_vpc.app.id }
resource "aws_route_table" "public" { vpc_id=aws_vpc.app.id; route { cidr_block="0.0.0.0/0"; gateway_id=aws_internet_gateway.app.id } }
resource "aws_route_table_association" "public" { count=2; subnet_id=aws_subnet.public[count.index].id; route_table_id=aws_route_table.public.id }
resource "aws_security_group" "alb" { name="tutedude-alb"; vpc_id=aws_vpc.app.id; ingress { from_port=80; to_port=80; protocol="tcp"; cidr_blocks=["0.0.0.0/0"] }; egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] } }
resource "aws_security_group" "tasks" { name="tutedude-tasks"; vpc_id=aws_vpc.app.id; ingress { from_port=3000; to_port=3000; protocol="tcp"; security_groups=[aws_security_group.alb.id] }; ingress { from_port=5000; to_port=5000; protocol="tcp"; security_groups=[aws_security_group.alb.id] }; egress { from_port=0; to_port=0; protocol="-1"; cidr_blocks=["0.0.0.0/0"] } }
resource "aws_ecr_repository" "flask" { name="tutedude-flask"; image_scanning_configuration { scan_on_push=true } }
resource "aws_ecr_repository" "express" { name="tutedude-express"; image_scanning_configuration { scan_on_push=true } }
resource "aws_ecs_cluster" "app" { name="tutedude-app" }
resource "aws_lb" "app" { name="tutedude-app"; load_balancer_type="application"; subnets=aws_subnet.public[*].id; security_groups=[aws_security_group.alb.id] }
resource "aws_lb_target_group" "frontend" { name="td-frontend"; port=3000; protocol="HTTP"; vpc_id=aws_vpc.app.id; target_type="ip"; health_check { path="/api/health"; matcher="200-499" } }
resource "aws_lb_target_group" "backend" { name="td-backend"; port=5000; protocol="HTTP"; vpc_id=aws_vpc.app.id; target_type="ip"; health_check { path="/api/health" } }
resource "aws_lb_listener" "http" { load_balancer_arn=aws_lb.app.arn; port=80; protocol="HTTP"; default_action { type="forward"; target_group_arn=aws_lb_target_group.frontend.arn } }
resource "aws_lb_listener_rule" "backend" { listener_arn=aws_lb_listener.http.arn; priority=10; action { type="forward"; target_group_arn=aws_lb_target_group.backend.arn }; condition { path_pattern { values=["/api/*"] } } }
resource "aws_iam_role" "ecs_task_execution" { name="tutedude-ecs-execution"; assume_role_policy=jsonencode({Version="2012-10-17",Statement=[{Action="sts:AssumeRole",Effect="Allow",Principal={Service="ecs-tasks.amazonaws.com"}}]}) }
resource "aws_iam_role_policy_attachment" "ecs_task_execution" { role=aws_iam_role.ecs_task_execution.name; policy_arn="arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" }
