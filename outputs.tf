output "cloudfront_url" {
    description = "URL for cloudfront deployment"
    value = length(aws_cloudfront_distribution.cloudfront) > 0 ? "https://${aws_cloudfront_distribution.cloudfront[0].domain_name}" : "CloudFront not deployed"
}

output "teamserver_public_ip" {
    value = length(aws_instance.teamserver) > 0 ? aws_instance.teamserver[0].public_ip : "Teamserver not deployed"
}

output "redirector_public_ip" {
  value = length(aws_instance.caddy_redirector) > 0 ? aws_instance.caddy_redirector[0].public_ip : "Redirector not deployed"
}

output "gophish_public_ip" {
  value = length(aws_instance.gophish-server) > 0 ? aws_instance.gophish-server[0].public_ip : "Gophish not deployed"
}

output "evilginx_public_ip" {
  value = length(aws_instance.evilginx-server) > 0 ? aws_instance.evilginx-server[0].public_ip: "Evilginx not deployed"
}