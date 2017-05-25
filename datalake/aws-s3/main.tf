#
# Data Lake using AWS S3
#

# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  profile    = "${var.aws_profile}"
  region     = "${var.aws_region}"
}

# Bucket to store logs from the data bucket
resource "aws_s3_bucket" "datalake_logs" {
  bucket = "${var.log_bucket_name}"
  acl    = "log-delivery-write"
}

# Reference to the AWS account in use
data "aws_caller_identity" "current" {}

# Policy to allow users to use the encryption key
data "template_file" "kms_usage_policy" {
  template = "${file(var.data_bucket_kms_usage_policy_file)}"

  vars {
    aws_account_id = "${data.aws_caller_identity.current.account_id}"
  }
}

# Data encryption key
resource "aws_kms_key" "default" {
  description = "Data encryption key for bucket: ${var.data_bucket_name}"
  policy      = "${data.template_file.kms_usage_policy.rendered}"
}

output "aws_kms_key_arn" {
  value = "${aws_kms_key.default.arn}"
}

# Data encryption key alias
resource "aws_kms_alias" "default" {
  name = "alias/${var.encryption_key_alias}"
  target_key_id = "${aws_kms_key.default.key_id}"
}

# Build up the Data Lake S3 bucket encryption policy from a template
data "template_file" "data_bucket_encryption_policy" {
  template = "${file(var.data_bucket_s3_encryption_policy_file)}"

  vars {
    data_bucket_name = "${var.data_bucket_name}"
  }
}

# Bucket for the data (the actual Data Lake)
resource "aws_s3_bucket" "datalake" {
  bucket    = "${var.data_bucket_name}"
  acl       = "private"

  # Encryption
  policy    = "${data.template_file.data_bucket_encryption_policy.rendered}"

  # Versioning
  versioning {
    enabled = "${var.data_bucket_versioning}"
  }

  # Logging
  logging {
    target_bucket = "${aws_s3_bucket.datalake_logs.id}"
    target_prefix = "log/"
  }

  tags {
    LogicalComponent    = "${var.logicalcomponent}"
    Owner               = "${var.owner}"
  }
}
