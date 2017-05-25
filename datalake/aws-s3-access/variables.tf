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

variable "data_bucket_s3_producers_access_policy_file" {
  description = "Access policy file to apply to data bucket to allow producers"
  default = "datalake-s3-producers-access-policy.json"
}

variable "data_bucket_s3_consumers_access_policy_file" {
  description = "Access policy file to apply to data bucket to allow consumers"
  default = "datalake-s3-consumers-access-policy.json"
}

variable "data_encryption_key_arn" {
  description = "ARN of the KMS key in use on the Data Lake, expected obtained after running the aws-s3 scripts in this same project"
}

variable "data_bucket_kms_usage_policy_file" {
  description = "Access policy file to apply to users to allow them to use the encryption key"
  default = "datalake-kms-usage-policy.json"
}