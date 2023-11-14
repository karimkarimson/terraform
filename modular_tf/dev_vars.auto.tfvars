# AWS Credentials
aws_profile = "techstarte"
region = "eu-central-1"

# Variables for EC2 Module
key_name = "ssh-october"
cidrs_ssh_ingress = ["84.153.40.149/32"]
cidrs_egress = ["0.0.0.0/0"]

# Variables for S3 Module
bucket_name = "karims-superdupercoolbucket1245"

# Variables for Instance Role Module
role_name = "karims-superdupercoolrole1245"
policy_actions = ["s3:*" ]
policy_effect = "Allow"