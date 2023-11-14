module "ec2" {
  source = "./modules/ec2"

  # Variables
  instance_profile = module.role.instance_role_name
  key_name = var.key_name
  profile_name = var.aws_profile
  cidrs_ssh_ingress = var.cidrs_ssh_ingress
  cidrs_egress = var.cidrs_egress

  # User-Data Script
  instance_script = <<-EOF
    #!/bin/bash
    echo "########## Updating Packages  #########" > /home/ec2-user/userdata.log
    sudo yum update -y
    echo "########## Upgrading Packages  #########" >> /home/ec2-user/userdata.log
    sudo yum upgrade -y
    echo "########## Downloading awscli  #########" >> /home/ec2-user/userdata.log
    sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    echo "########## Unpacking Packages  #########" >> /home/ec2-user/userdata.log
    sudo unzip awscliv2.zip
    echo "########## Installing AWS CLI  #########" >> /home/ec2-user/userdata.log
    sudo ./aws/install
    echo "########## Creating Text File  #########" >> /home/ec2-user/userdata.log
    sudo echo "Hello World from $(hostname -f)" > /home/ec2-user/helloworld.txt
    echo "########## Copy Textfile to S3  #########" >> /home/ec2-user/userdata.log
    aws s3 cp /home/ec2-user/helloworld.txt s3://karims-superdupercoolbucket1245/helloworld.txt
    echo "########## End of Script  #########" >> /home/ec2-user/userdata.log
    EOF
}

module "s3" {
  source = "./modules/s3"

  bucket_name = var.bucket_name
  bucket_encryption_enabled = true
}

module "role" {
  source = "./modules/iam"

  role_name = var.role_name
  policy_actions = var.policy_actions
  policy_effect = var.policy_effect

  policy_resources = [module.s3.bucket_arn, "${module.s3.bucket_arn}/*"]
}
