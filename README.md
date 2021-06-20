# terraform-aws

use these terraform files to provision a t2.mircro instance into your aws account, update secret values in terraform.tfvars
```
bash
$ git clone https://github.com/punitporwal07/terraform-aws.git
$ cd aws-terraform/
$ terraform init
$ terraform plan -out ami.tfplan
$ terraform apply "ami.tfplan"
```
