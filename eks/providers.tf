terraform {
  required_providers {
    aws        = {
      source   = "hashicorp/aws"
      version  = "4.36.1"
    }

    random     = {
      source   = "hashicorp/random"
      version  = "3.1.0"
    }
    kubernetes = {
      source   = "hashicorp/kubernetes"
      version  = "~> 2.0"
    }
  }

backend "s3" {
  bucket = "sd-cp-tf-state-us-east-1"
  key = "dev-terraform.tfstate"
  region = "us-east-1"
}
}

//provider "aws" {
//  region = var.region
//}

provider "kubernetes" {
  host                   = try(module.eks.cluster_endpoint, "foo")
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "bar")
  exec {
    api_version          = "client.authentication.k8s.io/v1"
    args                 = ["eks", "get-token", "--cluster-name", local.cluster_name]
    command              = "aws"
  }
}
