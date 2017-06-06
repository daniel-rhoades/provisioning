variable "aws_region" {
  description = "AWS region to launch servers"
  default     = "eu-west-1"
}

variable "aws_access_key" {
  description = "AWS access key, either specify this along with the secret key, or use a profile"
  default = ""
}

variable "aws_secret_key" {
  description = "AWS secret key, either specify this along with the access key, or use a profile"
  default = ""
}

variable "aws_profile" {
  description = "AWS profile, either use this or access/secret key combo"
  default = ""
}

variable "logicalcomponent" {
  description = "Name of this logical component within the architecture"
  default = "DataIngest"
}

variable "owner" {
  description = "Person or stage owning this infrastructure"
}

variable "data_bucket_name" {
  description = "AWS S3 bucket to use for the Data Lake"
}

variable "data_encryption_key_arn" {
  description = "ARN of the KMS key in use on the Data Lake, expected obtained after running the aws-s3 scripts in this same project"
}

variable "log_group_name" {
  description = "Name of the log group to report errors"
}

variable "log_stream_name" {
  description = "Name of the log group to report errors"
}

variable "buffer_interval" {
  default = 60
  description = "Batch interval duration for ingest"
}

variable "compression_format" {
  default = "Snappy"
  description = "Compression format to use on batched stream"
}

variable "bucket_prefix" {
  default = "INPUT/firehose/"
  description = "Prefix to use for folder/file name for ingested data"
}

variable "firehose_role_policy_file" {
  default = "firehose-role-policy.json"
  description = "Location of the file containing the role policy for firehose to use"
}

variable "datalake_ingest_access_policy_file" {
  default = "datalake-ingest-access-policy.json"
  description = "Location of the file containing the access policy for firehose to use"
}

variable "datalake_ingest_topic_name" {
  default = "datalake-ingest-topic"
  description = "Name of the topic to receive data for ingest into the Data Lake"
}

variable "lambda_role_policy_file" {
  default = "lambda-role-policy.json"
  description = "Location of the file containing the role policy for lambda to use"
}

variable "datalake_ingest_lambda_access_policy_file" {
  default = "datalake-ingest-lambda-access-policy.json"
  description = "Location of the file containing the access policy for Lambda to use to read from SNS and push to Kinesis"
}

variable "datalake_ingest_lambda_zip" {
  default = "sns-push-to-firehose.py.zip"
  description = "ZIP archive containing the function code for the ingester (SNS->Firehose)"
}

variable "datalake_ingest_lambda_handler" {
  default = "sns-push-to-firehose.lambda_handler"
  description = "Lambda function handle, e.g. filename.function_name"
}

variable "datalake_ingest_lambda_runtime" {
  default = "python2.7"
  description = "Lambda runtime"
}