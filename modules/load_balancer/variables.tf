variable "environment" { description = "The environment name or code which the resource(s) belong to." }
variable "owner"       { description = "The project owner(s) name or email address." }
variable "project"     { description = "The project's name or code which the resource(s) belong to." }

variable "role" {}

variable "lb_health_check_target" { default = "TCP:22" }

/*variable "lb_log_bucket"          {}
variable "lb_log_bucket_interval" { default = 60 }*/

variable "instance_port"      { default = 8080    }
variable "instance_protocol"  { default = "http"  }
variable "lb_port"            { default = 443     }
variable "lb_protocol"        { default = "https" }
# variable "ssl_certificate_id" {}

variable "lb_internal"        { default = false }
variable "lb_security_groups" { type = "list" }
variable "lb_subnets"         { type = "list" }
