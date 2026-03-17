provider "aws" {
    region  = "us-east-1"
    version = "~>2.0"
}

terraform {
    backend "s3" {
        # Lembre de trocar o bucket para o seu, não poder o mesmo nome
        bucket = "meu-primeiro_bucket"
        key    = "terraform-test.tfstate"
        region = "us-east-1"
    }

}