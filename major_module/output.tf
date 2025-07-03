# outputs.tf in root
output "instance_id" {s
  value = module.ec2_instance.instance_id
}

output "instance_public_ip" {
  value = module.ec2_instance.public_ip
}
