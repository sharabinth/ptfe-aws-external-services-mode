# Provision AWS EC2 Instance Using Terraform to Install pTFE in Demo Mode
Terraform configuration to setup AWS EC2 instance and a disk to be used in the Production mode using Mounted Disk option to install Private Terraform Enterprise.

# Usage
Make appropriate changes to the `vars.tf` file to replace with the values suitable for your environment such as key file name, aws region, hostname prefix, route53 domain name etc.  If using personal domain then remove route53 related config in the `main.tf` file.

Set environment variables AWS_SECRET_ACCESS_KEY and AWS_ACCESS_KEY_ID with the appropriate values to access the AWS environment.

```
$ git clone https://github.com/sharabinth/ptfe-aws-mounted-disk-mode.git
$ cd ptfe-aws-mounted-disk-mode
$ terraform init
$ terraform apply
```

# Setting Up TLS Certs
`setup-certs` folder contains a shell script which can be used to setup the TLS certs for the FQDN.  This script will install certbot and displays the required command to execute to generate the TLS certificates.

Copy the file to the Ubuntu host by establishing the SSH connection.

# How to install pTFE
SSH into the Ubuntu instance and execute the following

```
$ curl https://install.terraform.io/ptfe/stable > install.sh
$ sudo bash install.sh
```

The above is from the Terraform installation doc, please follow the public document to complete the Production Mounted Disk installation.
