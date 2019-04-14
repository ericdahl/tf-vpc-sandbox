provider "aws" {
  region = "us-east-1"
}


data "aws_ami" "freebsd_11" {
  most_recent = true

  owners = ["118940168514"]

  filter {
    name = "name"

    values = [
      "FreeBSD 12.0-STABLE-amd64*",
    ]
  }
}

resource "aws_instance" "jumphost" {
  ami                    = "${data.aws_ami.freebsd_11.image_id}"
  instance_type          = "t2.small"
  subnet_id              = "${aws_subnet.10_1_0_0_public1.id}"
  vpc_security_group_ids = [
    "${aws_security_group.10_1_0_0_allow_22.id}",
    "${aws_security_group.10_1_0_0_allow_vpc.id}",
    "${aws_security_group.10_1_0_0_allow_egress.id}"
  ]
  key_name               = "${var.key_name}"



  user_data = <<EOF
#!/usr/bin/env sh

export ASSUME_ALWAYS_YES=YES

pkg update -y
pkg install -y bash
chsh -s /usr/local/bin/bash ec2-user
EOF

  tags {
    Name = "jumphost"
  }
}
