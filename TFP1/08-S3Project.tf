terraform {
  backend "s3" {
    bucket  = "tfstate-p1-backend"
    key     = "terraform/state.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
