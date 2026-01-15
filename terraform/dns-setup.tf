# ============================================
# ROUTE 53 - DNS CONFIGURATION
# ============================================

# Route 53 Hosted Zone (Create if you don't have one)
# Note: Replace "example.com" with your actual domain
resource "aws_route53_zone" "main" {
  name = "painting.marketplace.com"

  tags = {
    Name = "application-zone"
  }
}

# DNS A Record pointing to ALB
resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "painting.marketplace.com"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# ============================================
# OUTPUTS
# ============================================

output "route53_zone_id" {
  description = "Route 53 Hosted Zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "route53_nameservers" {
  description = "Route 53 Nameservers"
  value       = aws_route53_zone.main.name_servers
}

output "dns_record_fqdn" {
  description = "Full domain name for ALB"
  value       = aws_route53_record.alb.fqdn
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}