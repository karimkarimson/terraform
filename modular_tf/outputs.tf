output "instance_ip" {
  value = module.ec2.instance_ip
}
output "bucket_url" {
  value = module.s3.bucket_url
}