resource "cloudflare_dns_record" "xyz_wildcard" {
  content = "${var.npm_ip_address}"
  name    = "*.${var.xyz_domain}"
  proxied = false
  ttl     = 1
  type    = "A"
  zone_id = data.bitwarden-secrets_secret.cf_xyz_zone_id.value
}

resource "cloudflare_dns_record" "outlook_autodiscover" {
  content = "autodiscover.outlook.com"
  name    = "autodiscover.${var.xyz_domain}"
  proxied = false
  ttl     = 3600
  type    = "CNAME"
  zone_id = data.bitwarden-secrets_secret.cf_xyz_zone_id.value
}

resource "cloudflare_dns_record" "selector1" {
  content = "selector1-mafyuh-xyz._domainkey.zg4dp.onmicrosoft.com"
  name    = "selector1._domainkey.${var.xyz_domain}"
  proxied = false
  ttl     = 3600
  type    = "CNAME"
  zone_id = data.bitwarden-secrets_secret.cf_xyz_zone_id.value
}

resource "cloudflare_dns_record" "selector2" {
  content = "selector2-mafyuh-xyz._domainkey.zg4dp.onmicrosoft.com"
  name    = "selector2._domainkey.${var.xyz_domain}"
  proxied = false
  ttl     = 3600
  type    = "CNAME"
  zone_id = data.bitwarden-secrets_secret.cf_xyz_zone_id.value
}

resource "cloudflare_dns_record" "outlook_mx" {
  content  = "mafyuh-xyz.mail.protection.outlook.com"
  name     = "${var.xyz_domain}"
  priority = 0
  proxied  = false
  ttl      = 3600
  type     = "MX"
  zone_id  = data.bitwarden-secrets_secret.cf_xyz_zone_id.value
}

resource "cloudflare_dns_record" "xyz_spf_record" {
  content = "\"v=spf1 include:spf.protection.outlook.com -all\""
  name    = "${var.xyz_domain}"
  proxied = false
  ttl     = 3600
  type    = "TXT"
  zone_id = data.bitwarden-secrets_secret.cf_xyz_zone_id.value
}

resource "cloudflare_dns_record" "xyz_verification" {
  content = "\"MS=ms45733080\""
  name    = "${var.xyz_domain}"
  proxied = false
  ttl     = 3600
  type    = "TXT"
  zone_id = data.bitwarden-secrets_secret.cf_xyz_zone_id.value
}