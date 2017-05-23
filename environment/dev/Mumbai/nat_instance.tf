# Rewards db servers security group
resource "aws_security_group" "Rewards_nat_sg" {
    name                    = "${var.project}_${var.environment}_${var.Rewards_nat_role}"
    vpc_id                  = "${module.vpc.vpc_id}"

    tags {
        Environment         = "${var.environment}"
        ManagedBy           = "Terraform"
        Name                = "${var.project}_${var.environment}_${var.Rewards_nat_role}"
        Owner               = "${var.owner}"
        Project             = "${var.project}"
        Role                = "${var.Rewards_nat_role}"
    }
}

resource "aws_security_group_rule" "from_external_to_Rewards_nat" {
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    cidr_blocks              = ["182.19.55.237/32"]
    security_group_id        = "${aws_security_group.Rewards_nat_sg.id}"
}

resource "aws_security_group_rule" "all_VPN_instances_to_Rewards_nat" {
    type                     = "ingress"
    from_port                = 0
    to_port                  = 65535
    protocol                 = "-1"
    cidr_blocks              = ["10.0.0.0/8"]
    security_group_id        = "${aws_security_group.Rewards_nat_sg.id}"
}
resource "aws_security_group_rule" "VPN_UDP_Port_to_Rewards_nat" {
    type                     = "ingress"
    from_port                = 1100
    to_port                  = 1100
    protocol                 = "udp"
    cidr_blocks              = ["0.0.0.0/0"]
    security_group_id        = "${aws_security_group.Rewards_nat_sg.id}"
}
resource "aws_security_group_rule" "to_external_from_Rewards_nat" {
    type                     = "egress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    cidr_blocks              = ["0.0.0.0/0"]
    security_group_id        = "${aws_security_group.Rewards_nat_sg.id}"
}

# Rewards NAT instance (This solution doesn't launch multiple instances in different subnets when `instance_count>1`)
module "Compute_Instance_Nat" {
    source                        = "../../../modules/ec2/no-volume"
    environment                   = "${var.environment}"
    project                       = "${var.project}"
    owner                         = "${var.owner}"
    role                          = "${var.Rewards_nat_role}"
    instance_count                = "${var.Rewards_nat_instance_count}"
    source_dest_check             = "${var.nat_source_dest_check}"
    associate_public_ip_address   = "${var.associate_public_ip_address}"
    instance_subnet_cidr_block    = "${element(var.public_cidr_blocks, 0)}"
    instance_subnet               = "${element(module.vpc.public_subnets, 0)}"
    instance_security_groups      = [ "${aws_security_group.Rewards_nat_sg.id}" ]
    instance_ami                  = "${var.nat_base_ami}"
    instance_type                 = "${var.Rewards_nat_instance_type}"
    instance_key_name             = "${var.rewards_nat_keypair_name}"
    user                          = "${var.nat_user}"
    package_manager               = "${var.nat_package_manager}"
}

resource "aws_eip" "NAT_Instance" {
  instance                        = "${element(module.Compute_Instance_Nat.instance_ids_out, 1)}"
  vpc                             = true
}
