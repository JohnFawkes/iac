output "cluster_id" {
  description = "OKE cluster OCID."
  value       = oci_containerengine_cluster.oke.id
}

output "cluster_endpoint" {
  description = "Private Kubernetes API endpoint."
  value       = oci_containerengine_cluster.oke.endpoints[0].kubernetes
}

output "worker_node_pool_id" {
  description = "pool1 node-pool OCID."
  value       = oci_containerengine_node_pool.pool1.id
}

output "vcn_id" {
  description = "OKE VCN OCID."
  value       = oci_core_vcn.oke.id
}
