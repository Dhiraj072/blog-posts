provider "aws" {
  # region you want your resource to be in
  region = "ap-southeast-1" 
}

terraform {
  backend = "local"
}

locals {
  s3_origin_id = "myappS3Origin"
  app_name = "my_app"
}

resource "aws_s3_bucket" "my_app" {
  bucket = "${local.app_name}" # S3 bucket name
  acl    = "public-read"
  website {
    index_document = "index.html" # our web app's entry point
  }
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicReadAccess",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${local.app_name}/*"
      ]
    }
  ]
}
POLICY
}