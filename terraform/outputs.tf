output "k8s_master_ip" {
  value = aws_instance.k8s_master_node.public_ip
}

output "k8s_worker_ip" {
  value = aws_instance.worker_nodes[0].public_ip
}
