remote_state {
  backend = "s3"
  config = {
    bucket = "terra-statefile-sre-zxcvbnm"
    region = "ap-south-1"
    key    = "sre-bucket/terraform.tfstate"
  }
}

#Terragrunt writes a temporary backend.tf file.
generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "s3" {}
}
EOF
}