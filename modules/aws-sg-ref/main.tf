



resource "aws_security_group" "default" {
  name        = var.security_group_name
  description = "${var.security_group_name} group managed by Terraform"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = var.ref_security_groups_ids
  description       = "All egress traffic"
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "tcp" {
  count             = var.tcp_ports == "default_null" ? 0 : length(split(",", var.tcp_ports))
  type              = "ingress"
  from_port         = split(",", var.tcp_ports)[count.index]
  to_port           = split(",", var.tcp_ports)[count.index]
  protocol          = "tcp"
  source_security_group_id = var.ref_security_groups_ids
  description       = ""
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "udp" {
  count             = var.udp_ports == "default_null" ? 0 : length(split(",", var.udp_ports))
  type              = "ingress"
  from_port         = split(",", var.udp_ports)[count.index]
  to_port           = split(",", var.udp_ports)[count.index]
  protocol          = "udp"
  source_security_group_id = var.ref_security_groups_ids
  description       = ""
  security_group_id = aws_security_group.default.id
}
