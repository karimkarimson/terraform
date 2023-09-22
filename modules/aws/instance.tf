resource "aws_instance" "instance_name" {
  ami                         = "ami-06dd92ecc74fdfb36" # Ubuntu 
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.vpc_name.id
  associate_public_ip_address = true
  key_name                    = "ssh-september" # SSH key name from AWS
  tags = {
    Name = "instance_name"
  }
  vpc_security_group_ids = [aws_security_group.instance_a_sg.id]
  user_data              = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt upgrade -y
              sudo apt install nginx -y
  EOF
}