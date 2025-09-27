output "master_ip" {
  value = aws_instance.master_node.public_ip
}

output "worker1_ip" {
  value = aws_instance.worker_nodes[0].public_ip
}

output "worker2_ip" {
  value = aws_instance.worker_nodes[1].public_ip
}
