resource "aws_vpc_endpoint" "client_interface" {
  vpc_id = aws_vpc.client.id

  vpc_endpoint_type = "Interface"
  service_name      = aws_vpc_endpoint_service.server.service_name

  subnet_ids = [for s in aws_subnet.client_public : s.id]

  security_group_ids = [aws_security_group.client_interface.id]

}

resource "aws_security_group" "client_interface" {
  vpc_id = aws_vpc.client.id
  name   = "private-link-cross-region-client-interface"
}

resource "aws_security_group_rule" "client_interface_ingress_http_client" {
  security_group_id = aws_security_group.client_interface.id

  type      = "ingress"
  from_port = 80
  protocol  = "tcp"
  to_port   = 80

  source_security_group_id = aws_security_group.client.id
}

resource "aws_security_group_rule" "client_interface_ingress_http_vpc_peer" {
  security_group_id = aws_security_group.client_interface.id

  type      = "ingress"
  from_port = 80
  protocol  = "tcp"
  to_port   = 80

  cidr_blocks = [var.peer_cidr_block]
}

output "client_pl_dns" {
  value = aws_vpc_endpoint.client_interface.dns_entry
}