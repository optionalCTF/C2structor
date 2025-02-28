resource "aws_instance" "caddy_redirector" {
  depends_on = [ aws_key_pair.C2structor-keypair ]
  count = var.ts-enabled ? 1 : 0
  ami = data.aws_ami.ubuntu_image.id
  instance_type = "t2.micro"
  key_name = var.ssh-keypair-name

  vpc_security_group_ids = [aws_security_group.sg-ssh_access.id, aws_security_group.sg-internet_access.id]

  user_data = <<-EOC
#!/bin/bash
sudo apt update -y
sudo apt install -y curl
# Install Caddy

sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update -y
sudo apt install -y caddy

# Create a decoy index.html
mkdir /var/www
mkdir /var/www/html
echo "<html><body><h1>Service Unavailable</h1></body></html>" > /var/www/html/index.html

# Set up Caddy config
cat <<EOF > /etc/caddy/Caddyfile
:80 {
        root * /var/www/html
        file_server

        @not_root {
                not path /
        }


        reverse_proxy @not_root ${aws_instance.teamserver[0].public_ip}:443 {
                transport http {
                        tls_insecure_skip_verify
                }
        }

        log {
                output file /var/log/caddy/access.log
                format json
        }
}
EOF

# Restart Caddy to apply config
systemctl restart caddy
EOC
              tags = {
                Name = "Caddy-Redirector" 
    }
}

resource "aws_route53_record" "caddy_redirector_dns" {
  count = var.ts-enabled ? 1 : 0
  zone_id = var.redirector-zoneid
  name = "${var.redirector-subdomain}.${var.redirector-domain}"
  type = "A"
  ttl = 300
  records = [aws_instance.caddy_redirector[0].public_ip]
  
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "cloudfront" {
  count = var.ts-enabled ? 1 : 0
  depends_on = [aws_instance.caddy_redirector]
  origin {
    domain_name = var.r53-domain ? aws_route53_record.caddy_redirector_dns[0].fqdn : format("%s.%s", var.redirector-subdomain, var.redirector-domain)
    origin_id   = "C2Redirector"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
        
    }

  }
  default_root_object = "/"
  enabled             = true

  default_cache_behavior {
    target_origin_id       = "C2Redirector"
    viewer_protocol_policy = "https-only"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = true
      headers = ["*"]
      cookies {
        forward = "all"
      }
    }
  
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
