# Terraform Kubernetes Sample Configuration
# This configuration demonstrates how to manage Kubernetes resources using Terraform
# Reference: https://github.com/hashicorp/terraform-provider-kubernetes

terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

# Configure the Kubernetes Provider
# This will use your current kubectl context
provider "kubernetes" {
  # Configuration options can be set here
  # For example, to specify a different config file:
  # config_path = "~/.kube/config"
  
  # Or to use a specific context:
  # config_context = "minikube"
}

# Create a namespace for our resources
resource "kubernetes_namespace" "example" {
  metadata {
    name = "terraform-k8s-example"
    
    labels = {
      "app.kubernetes.io/name"       = "terraform-example"
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = "demo"
    }
  }
}

# Create a ConfigMap for application configuration
resource "kubernetes_config_map" "example" {
  metadata {
    name      = "nginx-config"
    namespace = kubernetes_namespace.example.metadata[0].name
    
    labels = {
      "app.kubernetes.io/name"       = "nginx-example"
      "app.kubernetes.io/component"  = "config"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  data = {
    "nginx.conf" = <<-EOT
      events {
        worker_connections 1024;
      }
      
      http {
        server {
          listen 80;
          server_name localhost;
          
          location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
          }
          
          location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
          }
        }
      }
    EOT
    
    "index.html" = <<-EOT
      <!DOCTYPE html>
      <html>
      <head>
        <title>Terraform Kubernetes Sample</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; }
          .container { max-width: 600px; margin: 0 auto; }
          .header { color: #326ce5; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1 class="header">Hello from Terraform + Kubernetes!</h1>
          <p>This page is served by an nginx pod deployed using Terraform.</p>
          <p>Pod managed by: <strong>Terraform Kubernetes Provider</strong></p>
          <p>Namespace: <strong>terraform-k8s-example</strong></p>
        </div>
      </body>
      </html>
    EOT
  }
}

# Create a Pod running nginx
resource "kubernetes_pod" "nginx_example" {
  metadata {
    name      = "nginx-example"
    namespace = kubernetes_namespace.example.metadata[0].name
    
    labels = {
      "app.kubernetes.io/name"       = "nginx-example"
      "app.kubernetes.io/version"    = "1.0.0"
      "app.kubernetes.io/component"  = "web"
      "app.kubernetes.io/managed-by" = "terraform"
      "app"                          = "nginx-example"
    }
  }

  spec {
    container {
      image = "nginx:1.25-alpine"
      name  = "nginx"
      
      port {
        container_port = 80
        name           = "http"
        protocol       = "TCP"
      }
      
      # Resource limits and requests
      resources {
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }
      
      # Health checks
      liveness_probe {
        http_get {
          path = "/health"
          port = 80
        }
        initial_delay_seconds = 30
        period_seconds        = 10
      }
      
      readiness_probe {
        http_get {
          path = "/health"
          port = 80
        }
        initial_delay_seconds = 5
        period_seconds        = 5
      }
      
      # Mount the ConfigMap as a volume
      volume_mount {
        name       = "nginx-config"
        mount_path = "/etc/nginx"
        read_only  = true
      }
      
      volume_mount {
        name       = "nginx-html"
        mount_path = "/usr/share/nginx/html"
        read_only  = true
      }
      
      # Environment variables
      env {
        name  = "NGINX_PORT"
        value = "80"
      }
      
      env {
        name  = "ENVIRONMENT"
        value = "demo"
      }
    }
    
    # Volumes from ConfigMap
    volume {
      name = "nginx-config"
      config_map {
        name = kubernetes_config_map.example.metadata[0].name
        items {
          key  = "nginx.conf"
          path = "nginx.conf"
        }
      }
    }
    
    volume {
      name = "nginx-html"
      config_map {
        name = kubernetes_config_map.example.metadata[0].name
        items {
          key  = "index.html"
          path = "index.html"
        }
      }
    }
    
    # Pod restart policy
    restart_policy = "Always"
    
    # DNS policy
    dns_policy = "ClusterFirst"
  }
}

# Create a Service to expose the Pod
resource "kubernetes_service" "nginx_service" {
  metadata {
    name      = "nginx-service"
    namespace = kubernetes_namespace.example.metadata[0].name
    
    labels = {
      "app.kubernetes.io/name"       = "nginx-example"
      "app.kubernetes.io/component"  = "service"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    selector = {
      app = kubernetes_pod.nginx_example.metadata[0].labels.app
    }
    
    port {
      name        = "http"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    
    type = "ClusterIP"
  }
}

# Output values
output "namespace_name" {
  description = "The name of the created namespace"
  value       = kubernetes_namespace.example.metadata[0].name
}

output "pod_name" {
  description = "The name of the created pod"
  value       = kubernetes_pod.nginx_example.metadata[0].name
}

output "pod_ip" {
  description = "The IP address of the pod"
  value       = kubernetes_pod.nginx_example.status[0].pod_ip
}

output "service_name" {
  description = "The name of the created service"
  value       = kubernetes_service.nginx_service.metadata[0].name
}

output "service_cluster_ip" {
  description = "The cluster IP of the service"
  value       = kubernetes_service.nginx_service.spec[0].cluster_ip
}

output "configmap_name" {
  description = "The name of the created ConfigMap"
  value       = kubernetes_config_map.example.metadata[0].name
}

# Output instructions for verification
output "verification_commands" {
  description = "Commands to verify the deployment"
  value = {
    get_pods       = "kubectl get pods -n ${kubernetes_namespace.example.metadata[0].name}"
    get_services   = "kubectl get services -n ${kubernetes_namespace.example.metadata[0].name}"
    get_configmaps = "kubectl get configmaps -n ${kubernetes_namespace.example.metadata[0].name}"
    port_forward   = "kubectl port-forward -n ${kubernetes_namespace.example.metadata[0].name} pod/${kubernetes_pod.nginx_example.metadata[0].name} 8080:80"
    test_service   = "kubectl run test-pod --rm -i --tty --image=curlimages/curl -- curl ${kubernetes_service.nginx_service.metadata[0].name}.${kubernetes_namespace.example.metadata[0].name}.svc.cluster.local"
  }
}
