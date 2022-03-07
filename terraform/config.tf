terraform {
  required_version = ">= 0.14.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.46.0"
    }
  }
}

provider "local" {
  # Configuration options
}



provider "openstack" {
  # Must specify OS_CLOUD or AUTH_URL
}
