terraform {
  backend "s3" {
    region         = "us-east-1"
    key            = "426857564226/server.tfstate"
    bucket         = "krishna-tf-bucket"
    encrypt        = true
  }
}