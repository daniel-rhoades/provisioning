# Provisioning

Design and implementation for provisioning and configuring cloud IaaS/PaaS using [Terraform](https://www.terraform.io).
 
This repository is organised by the logical components it provisions.  Before following them though, please ensure you follow the "getting started" steps below.

## [Getting Started](#getting-started)

### AWS

If you haven't already got an AWS account, get one then:

1. Create an IAM user, download their access/secret key and attach the following AWS IAM policy to that user: `AdministratorAccess`;
2. Within the AWS console (within EC2), create an [SSH Key Pair](https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs:sort=keyName), this will be the key given to all EC2 instances, note the name you give to this Key Pair;

Not all logical components require an EC2 instance, so creating a key isn't necessarily essential.  

## Terraform

1. Install Terraform by following their [getting started guide](https://www.terraform.io/intro/getting-started/install.html);
2. To run any of the per-component provisioning scripts, clone this project then: `terraform apply -var "aws_access_key=<my-access-key>" -var "aws_secret_key=<my-secret-key>" -var "owner=<my-name>" -var "ec2_keyname=<my-key-name>"` within the component you want to provision;

All components make extensive use of variables to allow you to customise their usage, please see the documentation associated with each component, this will detail any additional variables that require setting.