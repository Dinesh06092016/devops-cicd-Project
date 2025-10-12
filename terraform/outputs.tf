output "k8s_master_ip" {
  description = "Public IP address of the Kubernetes master node"
  value       = aws_instance.k8s_master.public_ip
}

output "k8s_worker_ips" {
  description = "Public IP addresses of Kubernetes worker nodes"
  value       = aws_instance.k8s_worker[*].public_ip
}

output "k8s_master_dns" {
  description = "Public DNS of the Kubernetes master node"
  value       = aws_instance.k8s_master.public_dns
}

output "ssh_commands" {
  description = "SSH commands to connect to all nodes"
  value = {
    master = "ssh -i ~/.ssh/22nd-Sep.pem ubuntu@ec2-3-111-32-154.ap-south-1.compute.amazonaws.com
}"
    workers = [for i, worker in aws_instance.k8s_worker : "ssh -i ~/.ssh/22nd-Sep.pem ubuntu@${worker.public_dns}"]
  }
}
