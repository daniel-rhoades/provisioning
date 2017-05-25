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
  default = "Data Lake"
}

variable "owner" {
  description = "Person or stage owning this infrastructure"
}

variable "data_bucket_name" {
  description = "AWS S3 bucket to use for the Data Lake"
}

variable "data_bucket_versioning" {
  description = "Flag to enable versioning, default for a Data Lake should be true"
  default = true
}

variable "log_bucket_name" {
  description = "AWS S3 bucket to use for the Data Lake logging"
}

variable "encryption_key_alias" {
  description = "Alias for the AWS KMS"
}

variable "data_bucket_s3_encryption_policy_file" {
  description = "Encryption policy file to apply to data bucket"
  default = "datalake-s3-encryption-policy.json"
}

variable "data_bucket_s3_consumer_access_policy_file" {
  description = "Access policy file to apply to data bucket"
  default = "datalake-s3-consumer-access-policy.json"
}

variable "data_bucket_kms_usage_policy_file" {
  description = "Access policy file to apply to users to allow them to use the encryption key"
  default = "datalake-kms-usage-policy.json"
}