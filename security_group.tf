# Define the security group with all the ingress and egress rules

# Create Security Grouop with ingress / egress required for pTFE
resource "aws_security_group" "sec_group" {
  name        = "${var.resource_prefix_name}-sec-group"
  description = "${var.resource_prefix_name} security group"
  vpc_id      = "${aws_vpc.vpc.id}"

  # enable ingress to all by the security group
  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    self      = true
  }

  # enable ssh to do the pTFE installation
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  # enable http
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  # enable https access
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  # enable http access to pTFE dashboard
  ingress {
    protocol    = "tcp"
    from_port   = 8800
    to_port     = 8800
    cidr_blocks = ["0.0.0.0/0"]
  }

  # enable access to outside
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
