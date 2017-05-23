resource "aws_eip" "VPN_EIP" {
  vpc      = true
}

resource "aws_route53_record" "VPN_Domain" {
  zone_id = "${var.rewards_primary_zone_id}"
  name    = "${var.VPN_Domain}"
  type    = "A"
  ttl     = "60"
  records = ["${aws_eip.VPN_EIP.public_ip}"]
}
