

resource "aws_security_group" "internal" {

  name   = var.security_group_name
  vpc_id = var.vpcID

  dynamic "ingress" {
    for_each = var.ServicePorts
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
