resource "oci_core_route_table" "workers_and_pods" {
  compartment_id = data.bitwarden-secrets_secret.compartment_ocid.value
  display_name   = "oke-vcn-lan-private-rt"
  vcn_id         = oci_core_vcn.oke.id

  route_rules {
    description       = "traffic to the internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oke.id
  }

  route_rules {
    description       = "traffic to OCI services"
    destination       = data.oci_core_services.all_iad_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.oke.id
  }

  dynamic "route_rules" {
    for_each = var.home_network_cidrs
    content {
      description       = "home UniFi LAN"
      destination       = route_rules.value
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.oke.id
    }
  }
}

# Used by the private API endpoint and service-load-balancer subnets
resource "oci_core_route_table" "api_and_load_balancer" {
  compartment_id = data.bitwarden-secrets_secret.compartment_ocid.value
  display_name   = "oke-vcn-lan-public-rt"
  vcn_id         = oci_core_vcn.oke.id

  route_rules {
    description       = "private API endpoint internet egress through NAT gateway"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oke.id
  }

  route_rules {
    description       = "OKE private API endpoint access to OCI services"
    destination       = data.oci_core_services.all_iad_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.oke.id
  }

  dynamic "route_rules" {
    for_each = var.home_network_cidrs
    content {
      description       = "home UniFi LAN"
      destination       = route_rules.value
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_drg.oke.id
    }
  }
}
