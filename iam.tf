resource "aws_iam_policy" "s3_bucket_read" {
  name   = "${var.name_prefix}-s3-bucket-read"
  policy = module.s3_bucket_read.json
}

module "s3_bucket_read" {
  source  = "skrastrek/iam/aws//modules/policy-document/s3-bucket-read"
  version = "1.0.0"

  s3_bucket_arn = aws_s3_bucket.this.arn
}

resource "aws_iam_policy" "s3_bucket_write" {
  name   = "${var.name_prefix}-s3-bucket-write"
  policy = module.s3_bucket_write.json
}

module "s3_bucket_write" {
  source  = "skrastrek/iam/aws//modules/policy-document/s3-bucket-write"
  version = "1.0.0"

  s3_bucket_arn = aws_s3_bucket.this.arn
}
