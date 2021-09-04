//resource "aws_ec2_transit_gateway_route_table" "all" {
//  transit_gateway_id = aws_ec2_transit_gateway.default.id
//
//  tags = {
//    Name = "all"
//  }
//}
//
//resource "aws_ec2_transit_gateway_route" "all_blackhole" {
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.all.id
//  destination_cidr_block         = "0.0.0.0/0"
//  blackhole                      = true
//}
//
//resource "aws_ec2_transit_gateway_route" "all_10_1_0_0" {
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.all.id
//  destination_cidr_block         = "10.1.0.0/16"
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r10_1_0_0.id
//}
//
//resource "aws_ec2_transit_gateway_route" "all_10_2_0_0" {
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.all.id
//  destination_cidr_block         = "10.2.0.0/16"
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r10_2_0_0.id
//}
//
//resource "aws_ec2_transit_gateway_route" "all_10_3_0_0" {
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.all.id
//  destination_cidr_block         = "10.3.0.0/16"
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r10_3_0_0.id
//}
//
//resource "aws_ec2_transit_gateway_route" "all_10_4_0_0" {
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.all.id
//  destination_cidr_block         = "10.4.0.0/16"
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r10_4_0_0.id
//}
//
//resource "aws_ec2_transit_gateway_route" "all_10_5_0_0" {
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.all.id
//  destination_cidr_block         = "10.5.0.0/16"
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r10_5_0_0.id
//}
//
//resource "aws_ec2_transit_gateway_route_table_association" "all_10_1_0_0" {
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r10_1_0_0.id
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.all.id
//}
//
//resource "aws_ec2_transit_gateway_route_table_association" "all_10_3_0_0" {
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r10_3_0_0.id
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.all.id
//}
//
//resource "aws_ec2_transit_gateway_route_table_association" "all_10_5_0_0" {
//  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.r10_5_0_0.id
//  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.all.id
//}
//
