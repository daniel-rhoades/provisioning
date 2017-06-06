#
# Data Ingest with AWS Kinesis Firehose
#

# Specify the provider and access details
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  profile    = "${var.aws_profile}"
  region     = "${var.aws_region}"
}

# Define a role for Firehose to use
data "template_file" "firehose_role_policy" {
  template = "${file(var.firehose_role_policy_file)}"
}

resource "aws_iam_role" "firehose" {
  name = "firehose-${var.owner}"
  assume_role_policy = "${data.template_file.firehose_role_policy.rendered}"
}

# Reference to the AWS account in use
data "aws_caller_identity" "current" {}

# Define an access policy to allow Firehose to ingest data into the Data Lake
data "template_file" "firehose_access_policy" {
  template = "${file(var.datalake_ingest_access_policy_file)}"

  vars {
    dataLakeBucketName = "${var.data_bucket_name}"
    kmsArn = "${var.data_encryption_key_arn}"
    accountId = "${data.aws_caller_identity.current.account_id}"
  }
}

resource "aws_iam_policy" "firehose" {
  name        = "DataIngest-${var.owner}"
  description = "Policy that allows AWS Kinesis Firehose to push data into the Data Lake"
  policy      = "${data.template_file.firehose_access_policy.rendered}"
}

# Assign that policy to the role granted to Firehose
resource "aws_iam_role_policy_attachment" "firehose" {
  role      = "${aws_iam_role.firehose.name}"
  policy_arn = "${aws_iam_policy.firehose.arn}"
}

# CloudWatch logging
resource "aws_cloudwatch_log_group" "default" {
  name = "${var.log_group_name}-${var.owner}"
}

resource "aws_cloudwatch_log_stream" "default" {
  name = "${var.log_stream_name}"
  log_group_name = "${aws_cloudwatch_log_group.default.name}"
}

# Define the Firehose delivery stream
resource "aws_kinesis_firehose_delivery_stream" "default" {
  name        = "${var.logicalcomponent}-${var.owner}"
  destination = "s3"

  s3_configuration {
    role_arn   = "${aws_iam_role.firehose.arn}"
    bucket_arn = "arn:aws:s3:::${var.data_bucket_name}"
    prefix = "${var.bucket_prefix}"
    buffer_interval = "${var.buffer_interval}"
    compression_format = "${var.compression_format}"
    kms_key_arn = "${var.data_encryption_key_arn}"

    cloudwatch_logging_options {
      enabled = true
      log_group_name = "${aws_cloudwatch_log_group.default.name}"
      log_stream_name = "${aws_cloudwatch_log_stream.default.name}"
    }
  }
}

# Topic for receiving data to be ingested into the Data Lake
resource "aws_sns_topic" "ingest_topic" {
  name = "${var.datalake_ingest_topic_name}-${var.owner}"
}

# Role for a Lambda function to consume from SNS and push into Firehose
data "template_file" "lambda_role_policy" {
  template = "${file(var.lambda_role_policy_file)}"
}

resource "aws_iam_role" "datalake_consumer" {
  name = "datalake-consumer-${var.owner}"
  assume_role_policy = "${data.template_file.lambda_role_policy.rendered}"
}

data "template_file" "datalake_consumer_access_policy" {
  template = "${file(var.datalake_ingest_lambda_access_policy_file)}"
}

resource "aws_iam_policy" "datalake_consumer" {
  name        = "datalake-consumer-${var.owner}"
  description = "Policy that allows AWS Lambda to read from SNS and push to Kinesis"
  policy      = "${data.template_file.datalake_consumer_access_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "datalake_consumer" {
  role      = "${aws_iam_role.datalake_consumer.name}"
  policy_arn = "${aws_iam_policy.datalake_consumer.arn}"
}

# Lambda function to consume from SNS and push into Firehose
resource "aws_lambda_function" "datalake_consumer" {
  function_name    = "datalake-ingest-${var.owner}"
  role             = "${aws_iam_role.datalake_consumer.arn}"
  filename         = "${var.datalake_ingest_lambda_zip}"
  source_code_hash = "${base64sha256(file(var.datalake_ingest_lambda_zip))}"
  handler          = "${var.datalake_ingest_lambda_handler}"
  runtime          = "${var.datalake_ingest_lambda_runtime}"
}