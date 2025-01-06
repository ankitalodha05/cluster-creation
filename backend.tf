terraform {
  backend "s3" {
    bucket = "mytodoappbucket-eks"
    key    = "eks/terraform.tfstate"
    region = "us-west-2"
  }
}
