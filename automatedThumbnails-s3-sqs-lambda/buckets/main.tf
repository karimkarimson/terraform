terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

#* S3-Bucket
resource "aws_s3_bucket" "images" {
  bucket = "images-4569344686454j"

  tags = {
    Name = "images"
  }
}
resource "aws_s3_bucket" "thumbnails" {
  bucket = "thumbnails-913466129429x"

  tags = {
    Name = "thumbnails"
  }
}