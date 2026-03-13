resource "aws_key_pair" "EC2_Key_Pair" {
  key_name   = "EC2_Key_Pair"
  public_key = file(var.Pub_Key_Path)
}

resource "aws_key_pair" "ci_key_pair" {
  key_name   = "ci key pair"
  public_key = file(var.Pub_Key_Path_ci)
}

resource "aws_key_pair" "monitor_key_pair" {
  key_name   = "monitor key pair"
  public_key = file(var.Pub_Key_Path_monitor)
}