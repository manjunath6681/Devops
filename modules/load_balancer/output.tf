output "dns_name" {
  value = "${aws_elb.lb.dns_name}"
}
output "id" {
  value = "${aws_elb.lb.id}"
}
output "zone_id" {
  value = "${aws_elb.lb.zone_id}"
}
