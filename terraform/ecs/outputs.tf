output "alb_url" {

  value = "http://${aws_lb.app.dns_name}"
}
output "flask_ecr_url" {
  value = aws_ecr_repository.flask.repository_url
}
output "express_ecr_url" {
  value = aws_ecr_repository.express.repository_url
}
output "ecs_cluster" {
  value = aws_ecs_cluster.app.name
}
