data "template_file" "shellscript_template" {
    template = "${file("${path.module}/../files/shellscript.template")}"
    vars {
      user = "${var.user}"
      package_manager = "${var.package_manager}"
    }
}
data "template_cloudinit_config" "cloud_config" {
    gzip          = true
    base64_encode = false
    part {
        filename     = "shellscript.sh"
        content      = "${data.template_file.shellscript_template.rendered}"
        content_type = "text/x-shellscript"
    }
}
# EC2 instance
resource "aws_instance" "instance" {

    count = "${var.instance_count}"

    ami           = "${var.instance_ami}"
    instance_type = "${var.instance_type}"
    key_name      = "${var.instance_key_name}"
    source_dest_check = "${var.source_dest_check}"
    # include user_data script here, if any.
    user_data     = "${data.template_cloudinit_config.cloud_config.rendered}"

    subnet_id     = "${var.instance_subnet}"
    # private_ip    = "${cidrhost(var.instance_subnet_cidr_block,
                                # count.index)}"

    associate_public_ip_address = false
    monitoring                  = true
    vpc_security_group_ids      = [ "${var.instance_security_groups}" ]
    disable_api_termination     = false

    # false, because Mumbai region doesn't support
    ebs_optimized = false
    root_block_device {
        volume_type           = "gp2"
        volume_size           = 10
        delete_on_termination = true
    }
    ebs_block_device {
        device_name           = "/dev/sdf"
        volume_type           = "gp2"
        volume_size           = "${var.instance_config_volume_size}"
        delete_on_termination = true
        encrypted             = false
    }

    tags {
        Environment = "${var.environment}"
        Name        = "${var.project}-${var.environment}-${var.role}"
        Owner       = "${var.owner}"
        Project     = "${var.project}"
        role        = "${var.role}"
    }
}
