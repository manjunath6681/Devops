###############################
#   _____                     #
#  |_   _|__  ___  ___ ___    #
#    | |/ _ \/ __|/ __/ _ \   #
#    | |  __/\__ \ (_| (_) |  #
#    |_|\___||___/\___\___/   #
#                             #
###############################

# The project's name or code which the resource(s) belong to
variable "project"     { default = "Rewards" }

# The environment name or code which the resource(s) belong to
variable "environment" { default = "Dev" }

# The project owner(s) name or email address
variable "owner"       { default = "Colleague-DevOps" }

# Fully qualified domain name
variable "domain_name"  { default = "" }
variable "aws_region"  { default = "ap-south-1" }
variable "azs"         { default = [ "ap-south-1a", "ap-south-1b" ]}
provider "aws" {
    region  = "${var.aws_region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}

variable "access_key" {}
variable "secret_key" {}
# Network blocks
variable "vpc_cidr_block"         { default = "10.3.0.0/16"   }

variable "public_cidr_blocks"     { default = [ "10.3.0.0/24", "10.3.1.0/24" ]}
variable "private_cidr_blocks"    { default = [ "10.3.10.0/24", "10.3.11.0/24" ]}

variable  "rewards_primary_zone_id" { default = "ZKHY9DTXPSYXV" }
variable "VPN_Domain" { default = "mumbai_vpn"}

# VPC peering
variable "management_owner_id" { default = "530170256884" }
variable "management_vpc_id"   { default = "vpc-1367fb7a" }
variable "management_vpc_cidr" { default = "10.112.40.0/24" }
variable "management_route_table_id" {default = "rtb-eb432082" }
variable "management_public_sg" {default = "sg-67ba9c0e" }

# bastion instance variables
variable "Rewards_nat_role" { default = "NAT"}
variable "Rewards_nat_instance_count" { default = 1 }
variable "nat_base_ami" { default = "ami-48dcaa27" }
variable "nat_user" { default = "ec2-user" }
variable "nat_package_manager" { default = "yum" }
variable "Rewards_nat_instance_type" { default = "t2.small" }
variable "rewards_nat_keypair_name" { default = "non-prod-rewards-devops" }
variable "Rewards_nat_config_volume_size" { default = 20 }
variable "nat_source_dest_check" { default = false}
variable "associate_public_ip_address"  { default = true }

# App Load Balancer &  App Server variables
variable "Rewards_app_role" { default = "App"}
# variable "Rewards_cert_id" { default = 0 }
variable "Rewards_app_instance_count" { default = 1 }
# variable "Rewards_app_instance_offset" { default = 60 }
variable "app_base_ami" { default = "ami-1db5c172" }
variable "app_user" { default = "ec2-user" }
variable "app_package_manager" { default = "yum" }
variable "Rewards_app_instance_type" { default = "t2.large" }
variable "rewards_app_keypair_name" { default = "non-prod-rewards-devops" }
variable "app_source_dest_check" {
  default = true
}
variable "Rewards_app_config_volume_size" { default = 20 }

# db instance variables
variable "Rewards_db_role" { default = "DB"}
variable "Rewards_db_instance_count" { default = 3 }
variable "db_base_ami" { default = "ami-1db5c172" }
variable "db_user" { default = "ec2-user" }
variable "db_package_manager" { default = "yum" }
variable "Rewards_db_instance_type" { default = "t2.large" }
variable "rewards_db_keypair_name" { default = "non-prod-rewards-devops" }
variable "db_source_dest_check" {
  default = true
}
variable "Rewards_db_config_volume_size" { default = 20 }
