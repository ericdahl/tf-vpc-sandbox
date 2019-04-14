output "aws_instance.jumphost.public_ip" {
  value = "${aws_instance.jumphost.public_ip}"
}

output "data.aws_ami.freebsd_11.id" {
  value = "${data.aws_ami.freebsd_11.id}"
}