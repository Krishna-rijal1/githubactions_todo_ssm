provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      owner     = "krishna"
      silo      = "devsecops"
      terraform = true
      project   = "testvpc"
    }
  }
}