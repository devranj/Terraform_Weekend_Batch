resource "aws_s3_bucket" "rishi_s3_bucket" {
  bucket = "rishi-s3-bucket-demo-2025"
  tags = {
    Name        = "rishi-s3-bucket-demo-2025"
    Environment = "test"
  }
}

resource "aws_s3_object" "rishi_folder" {
  bucket = aws_s3_bucket.rishi_s3_bucket.bucket
  key    = "rishi_folder/"
}
resource "aws_s3_object" "rishi_file" {
  bucket = aws_s3_bucket.rishi_s3_bucket.bucket
  key    = "rishi_folder/hello.txt"
  source = "hello.txt"
  etag   = filemd5("hello.txt")
}