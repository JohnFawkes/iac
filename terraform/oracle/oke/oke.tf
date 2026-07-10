data "oci_identity_availability_domain" "ad1" {
  compartment_id = data.bitwarden-secrets_secret.compartment_ocid.value
  ad_number      = 1
}

data "oci_identity_availability_domain" "ad2" {
  compartment_id = data.bitwarden-secrets_secret.compartment_ocid.value
  ad_number      = 2
}

resource "oci_containerengine_cluster" "oke" {
  compartment_id     = data.bitwarden-secrets_secret.compartment_ocid.value
  name               = "cluster"
  kubernetes_version = "v1.36.1"
  type               = "BASIC_CLUSTER"
  vcn_id             = oci_core_vcn.oke.id

  cluster_pod_network_options {
    cni_type = "OCI_VCN_IP_NATIVE"
  }

  endpoint_config {
    is_public_ip_enabled = false
    subnet_id            = oci_core_subnet.api_endpoint.id
  }

  image_policy_config {
    is_policy_enabled = false
  }

  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }

    admission_controller_options {
      is_pod_security_policy_enabled = false
    }

    ip_families = ["IPv4"]

    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }

    persistent_volume_config {}
    service_lb_config {}

    service_lb_subnet_ids = [oci_core_subnet.service_load_balancers.id]
  }
}

# Node Pool
resource "oci_containerengine_node_pool" "pool1" {
  compartment_id     = data.bitwarden-secrets_secret.compartment_ocid.value
  cluster_id         = oci_containerengine_cluster.oke.id
  name               = "pool1"
  kubernetes_version = "v1.36.1"
  node_shape         = "VM.Standard.A1.Flex"

  initial_node_labels {
    key   = "name"
    value = "pool1"
  }

  node_config_details {
    size = 2

    node_pool_pod_network_option_details {
      cni_type          = "OCI_VCN_IP_NATIVE"
      max_pods_per_node = 31
      pod_subnet_ids    = [oci_core_subnet.workers_and_pods.id]
    }

    placement_configs {
      availability_domain = data.oci_identity_availability_domain.ad1.name
      subnet_id           = oci_core_subnet.workers_and_pods.id
    }

    placement_configs {
      availability_domain = data.oci_identity_availability_domain.ad2.name
      subnet_id           = oci_core_subnet.workers_and_pods.id
    }
  }

  node_eviction_node_pool_settings {
    eviction_grace_duration              = "PT1H"
    is_force_action_after_grace_duration = false
    is_force_delete_after_grace_duration = false
  }

  node_shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  node_source_details {
    image_id                = var.node_image_ocid
    source_type             = "IMAGE"
    boot_volume_size_in_gbs = 50
  }
}
