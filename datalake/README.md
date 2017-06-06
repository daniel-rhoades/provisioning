# Provisioning - Datalake

Terraform scripts for provisioning a Datalake in the following environments:

* AWS

## AWS

Provisioning is split into two components:

* aws-s3 - Builds the Data Lake;
* aws-s3-access - Provides an example access.

### aws-s3

Uses AWS S3 with appropriate controls for encryption, logging, etc.  For the full design please see [my corresponding blog article](http://danielrhoades.com/2017/05/24/how-do-you-build-a-data-lake-part1).

Before running the Terraform script, create a var file (e.g. `datalake.tfvars`) replacing the placeholders as required:

```bash
$ cat << EOF > datalake.tfvars
aws_profile           = "<AWS-PROFILE>"
owner                 = "<ME>"
data_bucket_name      = "<BUCKETNAME>"
log_bucket_name       = "<BUCKETNAME_FOR_LOGS"
encryption_key_alias  = "<KMS_ALIAS>"
EOF
```

* `aws_profile` will just be the profile name you setup after running the `aws configure` command;
* `owner` your name will be fine, or the name of the environment you are creating, e.g. dev;
* `data_bucket_name` S3 bucket name, e.g. datalake.mydomain.com;
* `log_bucket_name` S3 bucket for data lake access logs, e.g. datalake-logs.mydomain.com;
* `encryption_key_alias` Alias of the KMS key to use or create.

Then test the setup by asking Terraform to build a plan: `$ terraform plan --var-file=datalake.tfvars`.  If all is OK, then replace plan with `apply`.

### aws-s3-access

Provides an example creation of users controls who have access to the data lake.

Before running the Terraform script, create a var file (e.g. `datalake.tfvars`) replacing the placeholders as required:

```bash
$ cat << EOF > datalake.tfvars
aws_profile              = "<AWS-PROFILE>"
owner                    = "<ME>"
data_bucket_name         = "<BUCKETNAME>"
data_encryption_key_arn  = "<KMS_ARN>"
EOF
```

* `aws_profile` will just be the profile name you setup after running the `aws configure` command;
* `owner` your name will be fine, or the name of the environment you are creating, e.g. dev;
* `data_bucket_name` S3 bucket name, e.g. datalake.mydomain.com;
* `data_encryption_key_arn` ARN of the KMS key outputted from the previous script.

First we need to import the KMS key from the previous script:
 
```bash
$ terraform import --var-file=datalake.tfvars aws_kms_key.default <KMS_ARN>
```

Then create the users: `$ terraform apply --var-file=datalake.tfvars`.

You can then test the setup as per the blog article.

### aws-kinesis-firehose

Uses AWS SNS, Lambda and Kinesis to stream data into S3 - as in a Data Lake setup.  For the full design please see [my corresponding blog article](http://danielrhoades.com/2017/05/24/how-do-you-build-a-data-lake-part2).

Before running the Terraform script, create a var file (e.g. `datalake.tfvars`) replacing the placeholders as required:

```bash
$ cat << EOF > datalake.tfvars
aws_profile                   = "<AWS-PROFILE>"
owner                         = "<ME>"
data_bucket_name              = "<BUCKETNAME>"
data_encryption_key_arn       = "<KMS_ARN"
log_group_name                = "<MY_LOG_GROUP>
log_stream_name               = "<MY_LOG_STREAM>"
EOF
```

* `aws_profile` will just be the profile name you setup after running the `aws configure` command;
* `owner` your name will be fine, or the name of the environment you are creating, e.g. dev;
* `data_bucket_name` S3 bucket name, e.g. datalake.mydomain.com;
* `data_encryption_key_arn` ARN of the KMS key to be used for data encryption;
* `log_group_name` name of the log group, e.g. dev/datalake;
* `log_stream_name` name of the log stream, e.g. dataingest.

Then test the setup by asking Terraform to build a plan: `$ terraform plan --var-file=datalake.tfvars`.  If all is OK, then replace plan with `apply`.