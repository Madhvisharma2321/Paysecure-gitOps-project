resource "aws_ecr_repository" "paysecure_repo" {
  name = "paysecure-app"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = "dev"
    Project     = "PaySecure"
  }
}