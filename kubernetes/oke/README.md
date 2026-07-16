## Oracle Kubernetes Engine (OKE)

A 2 node test cluster running on Oracle Cloud's Always Free tier. Waiting to see if/how much Oracle charges me for this monthly to see if it stays, along with performance of workloads

See the [terraform config](/terraform/oracle/oke/).

## Specifications

- **Nodes:** 2 ARM nodes, each with 1 OCPU, 6 GB RAM, and a 50 GB boot disk (OCI allows 2 OCPU and 12GB RAM free)
- **Networking:** Oracle CNI and Envoy Gateway

## Structure

While this environment is being tested, its directory structure mirrors the
homelab layout. If OKE becomes a permanent part of the homelab, the overall
`/kubernetes` structure will be reorganized.
