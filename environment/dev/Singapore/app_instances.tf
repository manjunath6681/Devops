#
# Load Balancer (inc. Security Group)
#

# Rewards Service app server load balancer security group
resource "aws_security_group" "Rewards_app_lb_sg" {
    name                = "${var.project}_${var.environment}_LB"
    vpc_id              = "${module.vpc.vpc_id}"

    tags {
        Environment     = "${var.environment}"
        ManagedBy       = "Terraform"
        Name            = "${var.project}_${var.environment}_LB"
        Owner           = "${var.owner}"
        Project         = "${var.project}"
        Role            = "${var.Rewards_app_role}"
    }
}

# Rewards app Load Balancer security group - allow traffic from all
resource "aws_security_group_rule" "from_external_to_Rewards_app_lb" {
    type                = "ingress"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_id   = "${aws_security_group.Rewards_app_lb_sg.id}"

  }
resource "aws_security_group_rule" "to_external_from_Rewards_app_lb" {
    type                = "egress"
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    cidr_blocks         = ["0.0.0.0/0"]
    security_group_id   = "${aws_security_group.Rewards_app_lb_sg.id}"
}

# Rewards App Load Balancer
module "Rewards_LB" {
    source              = "../../../modules/load_balancer"
    environment         = "${var.environment}"
    project             = "${var.project}"
    owner               = "${var.owner}"
    role                = "${var.Rewards_app_role}"
    lb_security_groups  = [ "${aws_security_group.Rewards_app_lb_sg.id}" ]
    lb_subnets          = "${module.vpc.private_subnets}"

    instance_port       = "8080"
    instance_protocol   = "http"
    lb_port             = "443"
    lb_protocol         = "http"
    # ssl_certificate_id = "${var.Rewards_cert_id}"

    # change hearbeat URL, if required.
    lb_health_check_target = "HTTPS:8080/keepalive"

}

#
# Instance (inc. Security Group and ELB attachment)
#

# Rewards app servers security group
resource "aws_security_group" "Rewards_app_sg" {
    name        = "${var.project}_${var.environment}_${var.Rewards_app_role}"
    vpc_id      = "${module.vpc.vpc_id}"

    tags {
        Environment = "${var.environment}"
        ManagedBy   = "Terraform"
        Name        = "${var.project}_${var.environment}_${var.Rewards_app_role}"
        Owner       = "${var.owner}"
        Project     = "${var.project}"
        Role        = "${var.Rewards_app_role}"
    }
}

# Rewards app servers security group - allow traffic from Load Balancer
resource "aws_security_group_rule" "from_Rewards_app_lb_to_Rewards_app" {
    type                     = "ingress"
    from_port                = 8080
    to_port                  = 8080
    protocol                 = "tcp"
    source_security_group_id = "${aws_security_group.Rewards_app_lb_sg.id}"
    security_group_id        = "${aws_security_group.Rewards_app_sg.id}"
}

resource "aws_security_group_rule" "from_Rewards_bastion_to_Rewards_app" {
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    cidr_blocks              = ["10.0.0.0/8"]
    security_group_id        = "${aws_security_group.Rewards_app_sg.id}"
}

resource "aws_security_group_rule" "from_Ansible_master_to_Rewards_app" {
    type                     = "ingress"
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    cidr_blocks              = ["10.112.40.0/24"]
    security_group_id        = "${aws_security_group.Rewards_app_sg.id}"
}

resource "aws_security_group_rule" "to_external_from_Rewards_app" {
    type                     = "egress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    cidr_blocks              = ["0.0.0.0/0"]
    security_group_id        = "${aws_security_group.Rewards_app_sg.id}"
}

# Rewards app instance (This solution doesn't launch multiple instances in different subnets when `instance_count>1`)
module "Compute_Instance_App" {
    source                      = "../../../modules/ec2/1-volume"
    environment                 = "${var.environment}"
    project                     = "${var.project}"
    owner                       = "${var.owner}"
    role                        = "${var.Rewards_app_role}"
    instance_count              = "${var.Rewards_app_instance_count}"
    source_dest_check           = "${var.app_source_dest_check}"
    instance_subnet_cidr_block  = "${element(var.private_cidr_blocks, 0)}"
    instance_subnet             = "${element(module.vpc.private_subnets, 0)}"
    instance_security_groups    = [ "${aws_security_group.Rewards_app_sg.id}" ]
    instance_ami                = "${var.app_base_ami}"
    instance_type               = "${var.Rewards_app_instance_type}"
    instance_key_name           = "${var.rewards_app_keypair_name}"
    instance_config_volume_size = "${var.Rewards_app_config_volume_size}"
    user                        = "${var.app_user}"
    package_manager             = "${var.app_package_manager}"
}

# Giving syntax error while reading instance ids when `instance_count>1`
resource "aws_elb_attachment" "Rewards_app_attach" {
  elb      = "${module.Rewards_LB.id}"
  instance = "${join(",", module.Compute_Instance_App.instance_ids_out)}"
}
