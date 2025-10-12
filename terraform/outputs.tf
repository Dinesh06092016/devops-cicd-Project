output "instance_ips" {
  value = {
    master  = "3.111.32.154"
    workers = ["13.232.255.82"]
  }
}

output "k8s_master_ip" {
  value = "3.111.32.154"
}

output "k8s_master_dns" {
  value = "ec2-3-111-32-154.ap-south-1.compute.amazonaws.com"
}

output "k8s_worker_ips" {
  value = ["13.232.255.82"]
}

output "ssh_commands" {
  value = {
    master  = "ssh -i ~/.ssh/22nd-Sep.pem ubuntu@ec2-3-111-32-154.ap-south-1.compute.amazonaws.com"
    workers = [
      "ssh -i ~/.ssh/22nd-Sep.pem ubuntu@ec2-13-232-255-82.ap-south-1.compute.amazonaws.com"
    ]
  }
}
