terraform {
  backend "gcs" {
    bucket = "devops-358519-tf-state"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.31.0"
    }
  }
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

provider "google" {
  project = var.project
  region = var.region
}
