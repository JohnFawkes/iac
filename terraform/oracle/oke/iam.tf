resource "oci_identity_dynamic_group" "vcn_native_cni_workers" {
  compartment_id = data.bitwarden-secrets_secret.tenancy_ocid.value
  name           = "oke-vcn-native-cni-workers"
  description    = "Instance principals for OKE VCN-native CNI workers"
  matching_rule  = "ANY {instance.id = 'ocid1.instance.oc1.iad.anuwcljtt5oxdwqcwol2qk3x343eg2fodabjkkdeaorybkabsokcmkes3zxa', instance.id = 'ocid1.instance.oc1.iad.anuwcljrt5oxdwqczgzm2mkhegra54hdpizwjmvru7b6hyogi5pngtn5ejha'}"
}

resource "oci_identity_policy" "oke_service_vcn_native" {
  compartment_id = data.bitwarden-secrets_secret.tenancy_ocid.value
  name           = "oke-service-vcn-native-policy"
  description    = "Allow OKE service to manage VCN-native pod networking"
  statements = [
    "Allow service OKE to manage vnics in tenancy",
    "Allow service OKE to manage private-ips in tenancy",
    "Allow service OKE to read instances in tenancy",
  ]
}

resource "oci_identity_policy" "oke_vcn_native_cluster" {
  compartment_id = data.bitwarden-secrets_secret.tenancy_ocid.value
  name           = "oke-vcn-native-cni-cluster-policy"
  description    = "Allow this OKE cluster to manage VCN-native pod networking"
  statements = [
    "Allow any-user to manage instances in tenancy where all {request.principal.type = 'cluster', request.principal.id = '${oci_containerengine_cluster.oke.id}'}",
    "Allow any-user to use private-ips in tenancy where all {request.principal.type = 'cluster', request.principal.id = '${oci_containerengine_cluster.oke.id}'}",
    "Allow any-user to use network-security-groups in tenancy where all {request.principal.type = 'cluster', request.principal.id = '${oci_containerengine_cluster.oke.id}'}",
  ]
}

resource "oci_identity_policy" "oke_vcn_native_workers" {
  compartment_id = data.bitwarden-secrets_secret.tenancy_ocid.value
  name           = "oke-vcn-native-cni-workers-policy"
  description    = "Permit OKE worker instance principals to configure VCN-native pod networking"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.vcn_native_cni_workers.name} to inspect instances in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.vcn_native_cni_workers.name} to use vnics in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.vcn_native_cni_workers.name} to use private-ips in tenancy",
    "Allow dynamic-group ${oci_identity_dynamic_group.vcn_native_cni_workers.name} to use subnets in tenancy",
  ]
}
