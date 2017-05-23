# non-management vpc for hosting the application
module "vpc" {
  source                = "../../../modules/vpc"

  name                  = "${var.project}_${var.environment}"

  cidr                  = "${var.vpc_cidr_block}"
  private_subnets       = "${var.public_cidr_blocks}"
  public_subnets        = "${var.private_cidr_blocks}"
  enable_nat_gateway    = "true"
  enable_dns_hostnames  = "true"
  enable_dns_support    = "true"
  azs                   = "${var.azs}"

  tags {
    "Terraform"         = "true"
    "Environment"       = "${var.environment}"
    "Name"              = "${var.project}"
  }
}

# VPC Peering block
resource "aws_vpc_peering_connection" "management_peering" {
      peer_owner_id       = "${var.management_owner_id}"
      peer_vpc_id         = "${module.vpc.vpc_id}"
      vpc_id              = "${var.management_vpc_id}"
      auto_accept         = "true"
      tags {
        "Terraform"       = "true"
        "Environment"     = "${var.environment}"
        "Name"            = "${var.project}"
      }
}

resource "aws_route" "vpc_peering_public_route" {
    route_table_id              = "${element(module.vpc.public_route_table_ids, 0)}"
    destination_cidr_block      = "${var.management_vpc_cidr}"
    #count                      = "${length(var.public_cidr_blocks)}"
    vpc_peering_connection_id   = "${aws_vpc_peering_connection.management_peering.id}"
}

resource "aws_route" "mgmt_vpc_peering_public_route" {
    route_table_id            = "${var.management_route_table_id}"
    destination_cidr_block    = "${var.vpc_cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.management_peering.id}"
}

resource "aws_route" "vpc_peering_private_route" {
    route_table_id            = "${element(module.vpc.private_route_table_ids, count.index)}"
    destination_cidr_block    = "${var.management_vpc_cidr}"
    count                     = "${length(var.private_cidr_blocks)}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.management_peering.id}"
}
