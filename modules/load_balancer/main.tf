resource "aws_elb" "lb" {
    name = "${var.project}-${var.environment}-lb"

    connection_draining         = true
    connection_draining_timeout = 400
    cross_zone_load_balancing   = true
    idle_timeout                = 400
    internal                    = "${var.lb_internal}"
    security_groups             = [ "${var.lb_security_groups}" ]
    subnets                     = [ "${var.lb_subnets}" ]

    /*access_logs {
        bucket        = "${var.lb_log_bucket}"
        interval      = "${var.lb_log_bucket_interval}"
    }*/
    listener {
        instance_port      = "${var.instance_port}"
        instance_protocol  = "${var.instance_protocol}"
        lb_port            = "${var.lb_port}"
        lb_protocol        = "${var.lb_protocol}"
        # ssl_certificate_id = "${var.ssl_certificate_id}"
    }
    health_check {
        healthy_threshold   = 3
        unhealthy_threshold = 5
        timeout             = 5
        target              = "${var.lb_health_check_target}"
        interval            = 10
    }
    tags {
        Environment = "${var.environment}"
        ManagedBy   = "Terraform"
        Name        = "${var.project}-${var.environment}"
        Owner       = "${var.owner}"
        Project     = "${var.project}"
        role        = "${var.role}"
    }
}
