resource "aws_eip" "nat_gw" {
  vpc        = true
  depends_on = [aws_vpc.default]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw.id
  subnet_id     = aws_subnet.public["us-east-1a"].id
}