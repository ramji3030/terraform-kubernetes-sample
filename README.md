# Terraform Kubernetes Sample

A comprehensive sample Terraform project demonstrating Kubernetes resource management using the [Terraform Kubernetes Provider](https://github.com/hashicorp/terraform-provider-kubernetes).

## Overview

This project provides practical examples of how to use Terraform to provision and manage Kubernetes resources declaratively. It serves as a learning resource for Infrastructure as Code (IaC) practices with Kubernetes and demonstrates managing pods, services, and other Kubernetes objects through Terraform.

## Prerequisites

Before running this project, ensure you have:

- [Terraform](https://www.terraform.io/downloads.html) installed (v1.0+)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured with access to a Kubernetes cluster
- A running Kubernetes cluster (local with kind/minikube or cloud-based like AKS/EKS/GKE)
- Appropriate permissions to create resources in the target Kubernetes namespace

## Project Structure

```
terraform-kubernetes-sample/
├── main.tf          # Main Terraform configuration
├── README.md        # This file
└── .gitignore       # Git ignore file for Terraform
```

## Usage

### 1. Clone the Repository

```bash
git clone https://github.com/ramji3030/terraform-kubernetes-sample.git
cd terraform-kubernetes-sample
```

### 2. Configure Kubernetes Access

Ensure your kubectl is configured and can access your Kubernetes cluster:

```bash
kubectl cluster-info
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Plan the Deployment

```bash
terraform plan
```

### 5. Apply the Configuration

```bash
terraform apply
```

### 6. Verify the Deployment

Check the created resources:

```bash
kubectl get pods -l app=nginx-example
kubectl get services nginx-service
```

### 7. Clean Up Resources

When you're done, destroy the resources:

```bash
terraform destroy
```

## What This Project Creates

- **Pod**: A simple nginx pod with labels and resource limits
- **Service**: A ClusterIP service to expose the nginx pod internally
- **Namespace**: A dedicated namespace for organizing resources
- **ConfigMap**: Configuration data for the application

## Configuration Details

The main.tf file includes:

- **Kubernetes Provider**: Configuration to connect to your cluster
- **Namespace Resource**: Creates a dedicated namespace for isolation
- **Pod Resource**: Deploys an nginx pod with proper labels and specifications
- **Service Resource**: Exposes the pod through a Kubernetes service
- **ConfigMap Resource**: Demonstrates configuration management
- **Output Values**: Displays important resource information

## Customization

You can customize the deployment by modifying variables in main.tf:

- **Namespace name**: Change the namespace for resource isolation
- **Pod specifications**: Modify image, resources, or labels
- **Service configuration**: Adjust ports, selectors, or service type
- **ConfigMap data**: Update configuration values

## Key Features Demonstrated

- **Resource Management**: Creating, updating, and destroying Kubernetes resources
- **Dependencies**: Managing resource dependencies and creation order
- **Labels and Selectors**: Proper labeling strategy for resource organization
- **Configuration Management**: Using ConfigMaps for application configuration
- **Service Discovery**: Exposing applications through Kubernetes services

## Learning Resources

- [Terraform Kubernetes Provider Documentation](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)

## Official Provider Repository

This project uses the official Terraform Kubernetes Provider:
- **GitHub Repository**: [hashicorp/terraform-provider-kubernetes](https://github.com/hashicorp/terraform-provider-kubernetes)
- **Terraform Registry**: [kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest)

## Contributing

Feel free to submit issues and enhancement requests! Contributions are welcome.

## License

This project is provided as-is for educational purposes.

## Additional Examples

For more advanced examples and use cases, check out:
- [Terraform Kubernetes Provider Examples](https://github.com/hashicorp/terraform-provider-kubernetes/tree/main/examples)
- [Kubernetes Resource Management with Terraform](https://learn.hashicorp.com/tutorials/terraform/kubernetes-provider)
