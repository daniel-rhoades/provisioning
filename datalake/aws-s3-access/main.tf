#
# Access Control (via policy)
#

# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  profile    = "${var.aws_profile}"
  region     = "${var.aws_region}"
}

# Build up the Data Lake S3 bucket producer access policy from a template
data "template_file" "data_bucket_producers_access_policy" {
  template = "${file(var.data_bucket_s3_producers_access_policy_file)}"

  vars {
    data_bucket_name = "${var.data_bucket_name}"
    data_encryption_key_arn = "${var.data_encryption_key_arn}"
  }
}

# Group of users who produce into the lake
resource "aws_iam_group" "producers" {
  name = "DataLakeProducers-${var.owner}"
}

# Policy that allows producers to ingest into the lake
resource "aws_iam_policy" "producers" {
  name        = "DataLakeProducers-${var.owner}"
  description = "Policy that allows users to push raw data into the Data Lake"
  policy      = "${data.template_file.data_bucket_producers_access_policy.rendered}"
}

# Assign that policy to the producers group
resource "aws_iam_group_policy_attachment" "producers" {
  group      = "${aws_iam_group.producers.name}"
  policy_arn = "${aws_iam_policy.producers.arn}"
}

# Add a user to that producers group - bob
resource "aws_iam_user" "bob" {
  name = "bob"
}

# Create an IAM key for "bob"
resource "aws_iam_access_key" "bob" {
  user = "${aws_iam_user.bob.name}"
}

resource "aws_iam_group_membership" "producers" {
  name = "DataLakeProducer-${var.owner}-membership"

  users = [
    "${aws_iam_user.bob.name}"
  ]

  group = "${aws_iam_group.producers.name}"
}

output "bob_access_key_access" {
  value = "${aws_iam_access_key.bob.id}"
}

output "bob_access_key_secret" {
  value = "${aws_iam_access_key.bob.secret}"
}

# Build up the Data Lake S3 bucket consumer access policy from a template
data "template_file" "data_bucket_consumers_access_policy" {
  template = "${file(var.data_bucket_s3_consumers_access_policy_file)}"

  vars {
    data_bucket_name = "${var.data_bucket_name}"
    data_encryption_key_arn = "${var.data_encryption_key_arn}"
  }
}

# Group of users who consume from the lake
resource "aws_iam_group" "consumers" {
  name = "DataLakeConsumers-${var.owner}"
}

# Policy that allows consumers to read input and write output into the lake
resource "aws_iam_policy" "consumers" {
  name        = "DataLakeConsumers-${var.owner}"
  description = "Policy that allows users to push raw data into the Data Lake"
  policy      = "${data.template_file.data_bucket_consumers_access_policy.rendered}"
}

# Assign that policy to the producers group
resource "aws_iam_group_policy_attachment" "consumers" {
  group      = "${aws_iam_group.consumers.name}"
  policy_arn = "${aws_iam_policy.consumers.arn}"
}

# Add a user to that consumers group - fred
resource "aws_iam_user" "fred" {
  name = "fred"
}

resource "aws_iam_group_membership" "consumers" {
  name = "DataLakeConsumers-${var.owner}-membership"

  users = [
    "${aws_iam_user.fred.name}"
  ]

  group = "${aws_iam_group.producers.name}"
}

# Create an IAM key for "fred"
resource "aws_iam_access_key" "fred" {
  user = "${aws_iam_user.fred.name}"
}

output "fred_access_key_access" {
  value = "${aws_iam_access_key.fred.id}"
}

output "fred_access_key_secret" {
  value = "${aws_iam_access_key.fred.secret}"
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
  depends_on = ["aws_iam_access_key.fred", "aws_iam_access_key.bob"]
}