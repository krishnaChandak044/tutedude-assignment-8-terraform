output "flask_public_ip" {

  value = aws_instance.flask.public_ip
}
output "express_public_ip" {
  value = aws_instance.express.public_ip
}
output "frontend_url" {
  value = "http://${aws_instance.express.public_ip}:3000"
}
output "api_url" {
  value = "http://${aws_instance.flask.public_ip}:5000/api/health"
}
