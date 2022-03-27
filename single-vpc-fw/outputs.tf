output "ip" {
  value = {
    fw = {
      private = aws_instance.fw.private_ip,
#      admin = aws_network_interface.fw_wan.public_ip
    },
    internal = {
      private = aws_instance.internal.private_ip
    },
    jumphost = {
      public = aws_instance.jumphost.public_ip
    }
  }
}