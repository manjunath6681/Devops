variable "environment" { description = "The environment name or code which the resource(s) belong to." }
variable "owner"       { description = "The project owner(s) name or email address." }
variable "project"     { description = "The project's name or code which the resource(s) belong to." }
variable "user" {}
variable "role" {}
variable "package_manager" {}

variable "instance_count"  { default = 1 }
# variable "instance_offset" { default = 0 }
variable "instance_subnet_cidr_block" {}
variable "source_dest_check" {}

variable "instance_ami"      {}
variable "instance_type"     {}
variable "instance_key_name" {}

variable "instance_subnet"             {}
variable "instance_security_groups"    { type = "list" }
# variable "instance_config_volume_size" { default = 1 }
variable "associate_public_ip_address" { default = false }
