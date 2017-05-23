# Rewards db servers security group
resource "aws_security_group" "Rewards_db_sg" {
    name                     = "${var.project}_${var.environment}_${var.Rewards_db_role}"
    vpc_id                   = "${module.vpc.vpc_id}"
    tags {
        Environment          = "${var.environment}"
        ManagedBy            = "Terraform"
        Name                 = "${var.project}_${var.environment}_${var.Rewards_db_role}"
        Owner                = "${var.owner}"
        Project              = "${var.project}"
        Role                 = "${var.Rewards_db_role}"
    }
}

# Rewards db servers security group - allow traffic from app
resource "aws_security_group_rule" "from_Rewards_app_to_Rewards_db" {
    type                     = "ingress"
    from_port                = 27017
    to_port                  = 27017
    protocol                 = "tcp"
    cidr_blocks              = ["10.0.0.0/8"]
    security_group_id        = "${aws_security_group.Rewards_db_sg.id}"
}

resource "aws_security_group_rule" "from_All_VPN_Connected_Instance_to_Rewards__db" {
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    cidr_blocks              = ["10.0.0.0/8"]
    security_group_id        = "${aws_security_group.Rewards_db_sg.id}"
}

resource "aws_security_group_rule" "from_Ansible_master_to_Rewards_db" {
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    cidr_blocks              = ["10.112.40.0/24"]
    security_group_id        = "${aws_security_group.Rewards_db_sg.id}"
}

resource "aws_security_group_rule" "to_external_from_Rewards_db" {
    type                     = "egress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    cidr_blocks              = ["0.0.0.0/0"]
    security_group_id        = "${aws_security_group.Rewards_db_sg.id}"
}

# Rewards db instance (This solution doesn't launch multiple instances in different subnets when `instance_count>1`)
module "Compute_Instance_DB" {
    source                      = "../../../modules/ec2/2-volume"
    environment                 = "${var.environment}"
    project                     = "${var.project}"
    owner                       = "${var.owner}"
    role                        = "${var.Rewards_db_role}"
    instance_count              = "${var.Rewards_db_instance_count}"
    source_dest_check           = "${var.db_source_dest_check}"
    instance_subnet_cidr_block  = "${element(var.private_cidr_blocks, 0)}"
    instance_subnet             = "${element(module.vpc.private_subnets, 0)}"
    instance_security_groups    = [ "${aws_security_group.Rewards_db_sg.id}" ]
    instance_ami                = "${var.db_base_ami}"
    instance_type               = "${var.Rewards_db_instance_type}"
    instance_key_name           = "${var.rewards_db_keypair_name}"
    instance_config_volume_size = "${var.Rewards_db_config_volume_size}"
    user                        = "${var.db_user}"
    package_manager             = "${var.db_package_manager}"
}
