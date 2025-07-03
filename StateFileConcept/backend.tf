terraform {
  backend "s3" {
    bucket         = "ranjeet-s3-demo-xyz" # change this
    key            = "ranjeet/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}