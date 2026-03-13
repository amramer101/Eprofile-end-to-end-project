resource "aws_key_pair" "EC2_Key_Pair" {
  key_name   = "EC2_Key_Pair"
  public_key = file(var.pub_key_path)
}