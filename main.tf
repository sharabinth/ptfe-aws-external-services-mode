# Define the AWS provider
provider "aws" {
  # Use AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables
  region = "${var.aws_region}"
}

# use random pet for the DB password
resource "random_pet" "db_pwd" {
  length = 2
}

# define Route53 data source to retrieve the zone id
data "aws_route53_zone" "route53_zone" {
  name = "hashicorp-success.com."
}

# Create the Primary and Secondary EC2 instances to install pTFE.  
# Primary wil be active and secondary is cold standby
resource "aws_instance" "ptfe-demo" {
  count = 2

  ami           = "${var.amis}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.ssh_key_name}"

  # attach the security group
  vpc_security_group_ids = ["${aws_security_group.sec_group.id}"]

  # attach the subnets
  subnet_id = "${element(aws_subnet.subnet.*.id, count.index)}"
  
  # specify the IAM instance profile for ec2 to get access to s3 bucket for blob storage
  iam_instance_profile = "${aws_iam_instance_profile.ptfe_iam_profile.name}"

  # allocate atleast 40GB space for the pre-requisites
  root_block_device {
    volume_size = "${var.ebs_volume_size}"
    volume_type = "${var.ebs_volume_type}"
  }

  # tags to name
  tags {
    Name  = "${var.resource_prefix_name}-demo-${count.index+1}"
    owner = "${var.owner}"
  }
}

# Create elastic IP and attach it to the Primary EC2 instance
resource "aws_eip" "ptfe-demo" {
  instance = "${aws_instance.ptfe-demo.0.id}"
}

# Define the Route53 entry for the pTFE FQDN
resource "aws_route53_record" "route53_entry" {
  zone_id = "${data.aws_route53_zone.route53_zone.zone_id}"
  name    = "${var.resource_prefix_name}.hashicorp-success.com."
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.ptfe-demo.public_ip}"]
}

# create S3 bucket for the blob storage
resource "aws_s3_bucket" "s3_blob_storage" {
  bucket = "${var.resource_prefix_name}-s3-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name = "${var.resource_prefix_name}-s3-bucket"
  }
}

# create postgresQL database for pTFE
resource "aws_db_instance" "db" {
  allocated_storage         = 10
  engine                    = "postgres"
  engine_version            = "9.4"
  instance_class            = "db.t2.medium"
  identifier                = "${var.resource_prefix_name}-db-instance"
  name                      = "ptfe"
  storage_type              = "gp2"
  username                  = "ptfe"
  password                  = "${random_pet.db_pwd.id}"
  db_subnet_group_name      = "${aws_db_subnet_group.db_subnet_group.id}"
  vpc_security_group_ids    = ["${aws_security_group.sec_group.id}"]
  final_snapshot_identifier = "${var.resource_prefix_name}-db-inst-final-snapshot"
  multi_az                  = true
}

# Create the IAM role for EC2 instance to communicate to S3
# make sure that there is no space for the assume_role_policy
resource "aws_iam_role" "ptfe_iam" {
  name = "${var.resource_prefix_name}-iam_role"


  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "ptfe_iam_profile" {
  name = "${var.resource_prefix_name}-iam_instance_profile"
  role = "${aws_iam_role.ptfe_iam.name}"
}

data "aws_iam_policy_document" "ptfe_iam_policy" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.s3_blob_storage.id}",
      "arn:aws:s3:::${aws_s3_bucket.s3_blob_storage.id}/*",
    ]

    actions = [
      "s3:*",
    ]
  }
}

resource "aws_iam_role_policy" "ptfe_iam_role" {
  name   = "${var.resource_prefix_name}-iam_role_policy"
  role   = "${aws_iam_role.ptfe_iam.name}"
  policy = "${data.aws_iam_policy_document.ptfe_iam_policy.json}"
}
