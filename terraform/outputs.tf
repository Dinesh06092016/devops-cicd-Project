output "master_ip" {
  value = aws_instance.master_node.65.0.93.6
}

output "worker1_ip" {
  value = aws_instance.worker_nodes[0].13.232.106.40
}

output "worker2_ip" {
  value = aws_instance.worker_nodes[1].3.109.152.183
}
