<!--
Copyright (c) 2024, 2026, Oracle and/or its affiliates. All rights reserved.
The Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl/
-->

# Cassandra and Spark Data Locality Demo on OCI OKE

This automation deploys a full environment on [Oracle Kubernetes Engine (OKE)](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengoverview.htm) to demonstrate data locality between Apache Cassandra and Apache Spark using pod affinity and node labeling. The setup ensures Spark reads data from colocated Cassandra pods, reducing cross-node traffic.

# What it deploys

Using [Terraform](https://www.terraform.io/), the stack provisions:

**Network Module**

* **VCN (Virtual Cloud Network)** (unless using an existing one)
  * CIDR block configurable via VCN_CIDR
* Internet Gateway, NAT Gateway, Service Gateway
* Subnets
  * Public subnet (edge) for the bastion host
  * Private subnet for worker nodes
* Route Tables
  * Public subnet with route to Internet Gateway
  * Private subnet with route to NAT and Service Gateway
* Security lists

**OKE Module**

* OKE cluster
  * Configurable Kubernetes version (e.g. v1.33.1)
  * Private control plane by default
* OKE Node Pool
  * 3 worker nodes
  * Flex shape support (configurable OCPUs and memory)

**Bastion Module**

* Compute instance
  * Publich IP for SSH access
  * Automatically installs:
    * kubectl, helm, oci cli, python 3.9(via venv)
    * Cloud-native tools configured for instance principal auth
  * Cloud-init script executes the full demo:
    * Installs K8ssandra Operator (v1.7.1)
    * Deploys a 2-node Cassandra cluster
    * Applies node affinity (spark-locality) to place Cassandra on labeled nodes
    * Initializes test data in Cassandra
    * Deploys Spark master + 2 workers
    * Runs a Spark job that reads from Cassandra and outputs results

# Pre-Requisites

* OCI tenancy and a compartment
* Dynamic group and policies for instance principal.

# Deployment

** Deploy via OCI Resource Manager**

Get the code and upload it to the Oracle Resource Manager(ORM).

Follow the guided flow to:
* Select your compartment
* Configure the VCN, cluster name, and node shapes
* Launch the stack

# Post-Deployment: What to Expect

After deployment completes:

1. SSH into the bastion (public IP available in OCI Console)

2. Run `kubectl get nodes` and `kubectl get pods -A -o wide` to observe:

    * 2 Cassandra pods scheduled on 2 labeled nodes
    * 2 Spark workers colocated on the same nodes as Cassandra
    * The 3rd OKE node remains unused (no Spark/Cassandra workload)

3. Run this to see Spark read output:

    `kubectl logs job/spark-read-cassandra -n spark`

# Monitoring Data Locality

To confirm that the demo is working as expected:

* **VCN Flow Logs**
    1. Enable **Flow Logs** on the worker subnet (via OCI Console)
    2. Check the Cassandra pod traffic. You should not see inter-node traffic to the unused node - Spark is reading from Cassandra pods on the same nodes.

* **kubectl output**

Check pod placement:

```
kubectl get pods -A -o wide
kubectl get nodes --show-labels
```

# Implementation Details

* Cassandra deployed using K8ssandra Operator v1.7.1
* Data written to PVCs via oci block volume storage class
* Spark reads via Datastax Cassandra Connector with token-aware logic
* Spark job includes:
    * Python pyspark script reading from testks.users
    * Packaged via a ConfigMap and run as a Job

### Destroying the Stack

Before destroying the stack, it's recommended to clean up Kubernetes resources to ensure no pods or CRDs block the node pool or namespace deletion:

```
# Uninstall Helm releases
helm uninstall k8ssandra-operator -n k8ssandra-operator || true
helm uninstall cert-manager -n cert-manager || true

# Delete namespaces (and wait for resources to terminate)
kubectl delete namespace spark k8ssandra-operator cert-manager --ignore-not-found --wait=true

# Delete CRDs to avoid lingering finalizers
kubectl delete crd k8ssandraclusters.k8ssandra.io --ignore-not-found

```

Once cleanup completes, you can safely destroy the stack:

```
terraform destroy
```

Or use OCI Resource Manager to destroy the stack from the console.


