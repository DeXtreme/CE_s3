provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket-name
  force_destroy = true

  tags = {
    Name = "website-bucket-${var.bucket-name}"
  }
}

resource "aws_s3_object" "file" {
  for_each = fileset(path.module,"website/*")

  bucket = aws_s3_bucket.bucket.id
  key    = basename(each.value)
  source = each.value

}

resource "aws_s3_bucket_public_access_block" "bucket-pa" {
  bucket = aws_s3_bucket.bucket.id

  ignore_public_acls      = true
  block_public_acls       = true
  block_public_policy     = false
  restrict_public_buckets = false

}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.bucket.id
    policy = data.aws_iam_policy_document.public.json
}

data "aws_iam_policy_document" "public" {
  statement {
    principals {
      type = "*"
      identifiers = ["*"]
    }
    effect = "Allow"

    actions = [
        "s3:GetObject"
    ]

    resources = [ 
        aws_s3_bucket.bucket.arn,
        "${aws_s3_bucket.bucket.arn}/*"
     ]
  }
}

resource "aws_s3_bucket_website_configuration" "bucket-web" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "bucket-version" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}