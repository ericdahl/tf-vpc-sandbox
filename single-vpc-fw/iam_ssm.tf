resource "aws_iam_role" "ssm" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ssm_managed_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role = aws_iam_role.ssm.name
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${aws_iam_role.ssm.name}-instance-profile"
  role = aws_iam_role.ssm.name
}