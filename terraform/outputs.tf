output "instance_ips" {
  value = {
    master  = aws_instance.k8s_master.public_ip
    workers = [for w in aws_instance.k8s_worker : w.public_ip]
  }
}

output "k8s_instance_ips" {
  value = {
    master  = aws_instance.k8s_master.public_ip
    workers = [for w in aws_instance.k8s_worker : w.public_ip]
  }
}

output "k8s_master_dns" {
  value = aws_instance.k8s_master.public_dns
}

output "k8s_master_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "k8s_worker_ips" {
  value = [for w in aws_instance.k8s_worker : w.public_ip]
}

output "k8s_ssh_commands" {
  value = {
    master = "ssh -i ~/.ssh/22nd-sep.pem ubuntu@${aws_instance.k8s_master.public_dns}"
    workers = [
      for w in aws_instance.k8s_worker : "ssh -i ~/.ssh/22nd-sep.pem ubuntu@${w.public_dns}"
    ]
  }
}
