# Core private OKE network.
resource "oci_core_vcn" "oke" {
  compartment_id = data.bitwarden-secrets_secret.compartment_ocid.value
  display_name   = "oke-vcn-lan"
  dns_label      = "okelan"
  cidr_blocks    = ["10.100.0.0/16"]
}

resource "oci_core_default_dhcp_options" "oke" {
  manage_default_resource_id = oci_core_vcn.oke.default_dhcp_options_id
  compartment_id             = data.bitwarden-secrets_secret.compartment_ocid.value
  display_name               = "Default DHCP Options for oke-vcn-lan"
  domain_name_type           = "CUSTOM_DOMAIN"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["okelan.oraclevcn.com"]
  }
}

resource "oci_core_nat_gateway" "oke" {
  compartment_id = data.bitwarden-secrets_secret.compartment_ocid.value
  display_name   = "oke-vcn-lan-ngw"
  vcn_id         = oci_core_vcn.oke.id
  block_traffic  = false
}

resource "oci_core_internet_gateway" "oke" {
  compartment_id = data.bitwarden-secrets_secret.compartment_ocid.value
  display_name   = "oke-vcn-lan-igw"
  vcn_id         = oci_core_vcn.oke.id
  enabled        = true
}

data "oci_core_services" "all_iad_services" {
  filter {
    name   = "name"
    values = ["All IAD Services In Oracle Services Network"]
  }
}

resource "oci_core_service_gateway" "oke" {
  compartment_id = data.bitwarden-secrets_secret.compartment_ocid.value
  display_name   = "oke-vcn-lan-sgw"
  vcn_id         = oci_core_vcn.oke.id

  services {
    service_id = data.oci_core_services.all_iad_services.services[0].id
  }
}

resource "oci_core_subnet" "api_endpoint" {
  compartment_id             = data.bitwarden-secrets_secret.compartment_ocid.value
  display_name               = "oke-vcn-lan-k8sApiEndpoint-subnet-regional"
  dns_label                  = "apisub"
  vcn_id                     = oci_core_vcn.oke.id
  cidr_block                 = "10.100.0.0/28"
  dhcp_options_id            = oci_core_default_dhcp_options.oke.id
  route_table_id             = oci_core_route_table.api_and_load_balancer.id
  security_list_ids          = [oci_core_security_list.api_endpoint.id]
  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "workers_and_pods" {
  compartment_id             = data.bitwarden-secrets_secret.compartment_ocid.value
  display_name               = "oke-vcn-lan-nodesubnet-regional"
  dns_label                  = "nodesub"
  vcn_id                     = oci_core_vcn.oke.id
  cidr_block                 = "10.100.10.0/24"
  dhcp_options_id            = oci_core_default_dhcp_options.oke.id
  route_table_id             = oci_core_route_table.workers_and_pods.id
  security_list_ids          = [oci_core_security_list.workers_and_pods.id]
  prohibit_internet_ingress  = true
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "service_load_balancers" {
  compartment_id             = data.bitwarden-secrets_secret.compartment_ocid.value
  display_name               = "oke-vcn-lan-svclbsubnet-regional"
  dns_label                  = "lbsub"
  vcn_id                     = oci_core_vcn.oke.id
  cidr_block                 = "10.100.20.0/24"
  dhcp_options_id            = oci_core_default_dhcp_options.oke.id
  route_table_id             = oci_core_route_table.api_and_load_balancer.id
  security_list_ids          = [oci_core_security_list.service_load_balancers.id]
  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
}
