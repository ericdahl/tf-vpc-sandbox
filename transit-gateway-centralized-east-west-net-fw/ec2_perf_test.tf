#resource "aws_security_group" "perf_test" {
#  vpc_id = module.vpc_dev["10.1.0.0/16"].vpc.id
#  name   = "perf_test_1_0_0_0"
#}
#
#resource "aws_security_group_rule" "perf_test_egress" {
#  security_group_id = aws_security_group.perf_test.id
#  type              = "egress"
#  from_port         = 0
#  to_port           = 0
#  protocol          = "-1"
#  cidr_blocks       = ["0.0.0.0/0"]
#}
#
#resource "aws_security_group_rule" "perf_test_ingress_all_rfc1918" {
#  security_group_id = aws_security_group.perf_test.id
#  type              = "ingress"
#  from_port         = 0
#  to_port           = 0
#  protocol          = "-1"
#  cidr_blocks       = ["10.0.0.0/8"]
#}
#resource "aws_placement_group" "default" {
#  name     = "perf"
#  strategy = "cluster"
#}
#
#data "aws_ssm_parameter" "amazon_linux_2" {
#  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
#}
#
#resource "aws_instance" "perf_testing" {
#  count           = 2
#  placement_group = aws_placement_group.default.id
#
#  ami                    = data.aws_ssm_parameter.amazon_linux_2.value
#  subnet_id              = module.vpc_dev["10.1.0.0/16"].subnets["private"]["us-east-1a"].id
#  vpc_security_group_ids = [aws_security_group.perf_test.id]
#  instance_type          = "c5n.large"
#
#  key_name = aws_key_pair.default.key_name
#
#
#  tags = {
#    Name = "perf"
#  }
#}