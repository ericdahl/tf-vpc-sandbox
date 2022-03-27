resource "aws_flow_log" "default" {
  vpc_id       = aws_vpc.default.id
  traffic_type = "ALL"

  log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
  iam_role_arn    = aws_iam_role.vpc_flow_log.arn

  # default
  # log_format = "${version} ${account-id} ${interface-id} ${srcaddr} ${dstaddr} ${srcport} ${dstport} ${protocol} ${packets} ${bytes} ${start} ${end} ${action} ${log-status}"

  max_aggregation_interval = 60
#  log_format = "$${interface-id} $${pkt-srcaddr} ( $${srcaddr} ) => $${pkt-dstaddr} ( $${dstaddr} ) proto=$${protocol} bytes=$${bytes} start=$${start}"
#  log_format = "$${interface-id}  $${pkt-srcaddr}  $${srcaddr} "

  #  log_format = "interface-id start srcaddr pkt-srcaddr => dstaddr pkt-dstaddr flow-direction protocol"
  log_format = "$${interface-id} $${pkt-srcaddr} $${srcaddr} $${flow-direction} $${bytes} $${dstaddr} $${pkt-dstaddr} $${end} $${packets} $${protocol} $${start} $${type}"
}


resource "aws_cloudwatch_log_group" "vpc_flow_log" {
  name = "vpc-flow-log-${aws_vpc.default.cidr_block}"
}

resource "aws_iam_role" "vpc_flow_log" {
  name = "vpc-flow-log-${cidrhost(aws_vpc.default.cidr_block, 0)}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flow_log" {
  name = "vpc-flow-log-${cidrhost(aws_vpc.default.cidr_block, 0)}"
  role = aws_iam_role.vpc_flow_log.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}