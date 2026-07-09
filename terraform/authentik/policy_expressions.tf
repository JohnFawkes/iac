## https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/policy_expression
## /api/v3/#get-/policies/expression/

resource "authentik_policy_expression" "default-authentication-flow-password-stage" {
  name       = "default-authentication-flow-password-stage"
  expression = "flow_plan = request.context.get(\"flow_plan\")\nif not flow_plan:\n    return True\n# If the user does not have a backend attached to it, they haven't\n# been authenticated yet and we need the password stage\nreturn not hasattr(flow_plan.context.get(\"pending_user\"), \"backend\")"
}

resource "authentik_policy_expression" "default-oobe-password-usable" {
  name       = "default-oobe-password-usable"
  expression = "# This policy ensures that the setup flow can only be\n# executed when the admin user doesn't have a password set\nakadmin = ak_user_by(username=\"akadmin\")\n# Ensure flow was started correctly\nstarted_by = context.get(\"goauthentik.io/core/setup/started-by\")\nif started_by != \"setup\":\n    setup_url = request.http_request.build_absolute_uri(\"/\")\n    ak_message(f\"Access the authentik setup by navigating to {setup_url}\")\n    return False\nreturn akadmin is None or not akadmin.has_usable_password()"
}

resource "authentik_policy_expression" "default-oobe-prefill-user" {
  name       = "default-oobe-prefill-user"
  expression = "# This policy sets the user for the currently running flow\n# by injecting \"pending_user\"\nakadmin = ak_user_by(username=\"akadmin\")\ncontext[\"flow_plan\"].context[\"pending_user\"] = akadmin\nreturn True"
}

resource "authentik_policy_expression" "default-source-authentication-if-sso" {
  name       = "default-source-authentication-if-sso"
  expression = "# This policy ensures that this flow can only be used when the user\n# is in a SSO Flow (meaning they come from an external IdP)\nreturn ak_is_sso_flow"
}

resource "authentik_policy_expression" "default-source-enrollment-if-sso" {
  name       = "default-source-enrollment-if-sso"
  expression = "# This policy ensures that this flow can only be used when the user\n# is in a SSO Flow (meaning they come from an external IdP)\nreturn ak_is_sso_flow"
}

resource "authentik_policy_expression" "default-source-enrollment-if-username" {
  name       = "default-source-enrollment-if-username"
  expression = "# Check if we''ve not been given a username by the external IdP\n# and trigger the enrollment flow\nreturn 'username' not in context.get('prompt_data', {})"
}

resource "authentik_policy_expression" "default-user-settings-authorization" {
  name       = "default-user-settings-authorization"
  expression = "from authentik.core.models import (\n    USER_ATTRIBUTE_CHANGE_EMAIL,\n    USER_ATTRIBUTE_CHANGE_NAME,\n    USER_ATTRIBUTE_CHANGE_USERNAME\n)\nprompt_data = request.context.get(\"prompt_data\")\n\nif not request.user.group_attributes(request.http_request).get(\n    USER_ATTRIBUTE_CHANGE_EMAIL, request.http_request.tenant.default_user_change_email\n):\n    if prompt_data.get(\"email\") != request.user.email:\n        ak_message(\"Not allowed to change email address.\")\n        return False\n\nif not request.user.group_attributes(request.http_request).get(\n    USER_ATTRIBUTE_CHANGE_NAME, request.http_request.tenant.default_user_change_name\n):\n    if prompt_data.get(\"name\") != request.user.name:\n        ak_message(\"Not allowed to change name.\")\n        return False\n\nif not request.user.group_attributes(request.http_request).get(\n    USER_ATTRIBUTE_CHANGE_USERNAME, request.http_request.tenant.default_user_change_username\n):\n    if prompt_data.get(\"username\") != request.user.username:\n        ak_message(\"Not allowed to change username.\")\n        return False\n\nreturn True"
}
