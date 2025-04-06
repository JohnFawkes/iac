resource "cloudflare_zero_trust_access_identity_provider" "authentik_access_identity_provider" {
  account_id = data.bitwarden-secrets_secret.cf_account_id.value
  config = {
    auth_url  = "https://auth.${var.io_domain}/application/o/authorize/"
    certs_url = "https://auth.${var.io_domain}/application/o/cloudflare/jwks/"
    client_id = "HaRwyfeUlBCzdypqDU7hhsYTy7Ndaa4kyypQaK9A"
    scopes    = ["openid", "email", "profile"]
    token_url = "https://auth.${var.io_domain}/application/o/token/"
  }
  name = "authentik"
  type = "oidc"
  scim_config = {
    enabled = false
    seat_deprovision = false
    user_deprovision = false
  }
}