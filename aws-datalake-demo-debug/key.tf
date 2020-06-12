resource "aws_key_pair" "key" {
  key_name   = "key"
  public_key = file("test-key.pub")
}

# resource "aws_key_pair" "key-keygen" {
#   key_name   = "key"
#   public_key = file("mykey.pub")
# }




