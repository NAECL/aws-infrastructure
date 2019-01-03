resource "aws_s3_bucket" "demo_bucket" {
  bucket = "${var.demobucket}"
  acl    = "public-read"
  policy = "${file("bucket.json")}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
