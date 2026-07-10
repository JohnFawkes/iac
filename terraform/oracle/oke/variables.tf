variable "region" {
  description = "OCI region containing the OKE cluster."
  type        = string
  default     = "us-ashburn-1"
}

variable "access_token" {
  description = "Bitwarden Secrets Manager access token."
  type        = string
  sensitive   = true
}

variable "node_image_ocid" {
  description = "Oracle Linux ARM image OCID currently used by pool1. Update deliberately when upgrading worker images."
  type        = string
  default     = "ocid1.image.oc1.iad.aaaaaaaacnk7bzffbgo7lyhwshn5lnr4ls227i2nsoznkmj4a3immucy7deq"
}

variable "home_network_cidrs" {
  description = "Networks reachable over the IPSec connection to the home UniFi router."
  type        = list(string)
  default = [
    "10.0.0.0/24",
    "10.69.69.0/24",
    "10.20.10.0/24",
    "10.10.34.0/24",
  ]
}
