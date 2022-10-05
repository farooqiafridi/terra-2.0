
resource "aws_key_pair" "keypair" {
  key_name   = var.key-name
  public_key = var.public-key
}
