# Output the Kubernetes master public IP
output "k8s_master_ip" {
  value = aws_instance.k8s_master.public_ip
}

# Output the Kubernetes worker public IPs
output "k8s_worker_ips" {
  value = [for w in aws_instance.k8s_worker : w.public_ip]
}

# Output SSH command examples to connect to master and workers
output "k8s_ssh_commands" {
  value = {
    master  = "ssh -i ~/.ssh/22nd-Sep.pem ubuntu@${aws_instance.k8s_master.public_ip}"
    workers = [for w in aws_instance.k8s_worker : "ssh -i ~/.ssh/22nd-Sep.pem ubuntu@${w.public_ip}"]
  }
}
