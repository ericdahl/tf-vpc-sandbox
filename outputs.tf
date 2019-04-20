output "aws_instance.10_1_0_0_jumphost.public_ip" {
  value = "${aws_instance.10_1_0_0_jumphost.public_ip}"
}

output "aws_instance.10_1_0_0_jumphost.private_ip" {
  value = "${aws_instance.10_1_0_0_jumphost.private_ip}"
}

output "aws_instance.10_2_0_0_jumphost.public_ip" {
  value = "${aws_instance.10_2_0_0_jumphost.public_ip}"
}

output "aws_instance.10_2_0_0_jumphost.private_ip" {
  value = "${aws_instance.10_2_0_0_jumphost.private_ip}"
}

output "data.aws_ami.freebsd_11.id" {
  value = "${data.aws_ami.freebsd_11.id}"
}
