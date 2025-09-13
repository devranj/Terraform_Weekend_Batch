resource "aws_s3_bucket" "aatifsaharbucket1" {
  bucket = "aatif-sahar-bucket1"

  tags = {
    Name        = "aatifsahar bucket"
    Environment = "test"
  }
}