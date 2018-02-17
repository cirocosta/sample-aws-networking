# Creates a mapping between subnet name and generated subnet ID.
output "az-subnet-id-mapping" {
  value = "${zipmap(aws_subnet.main.*.tags.Name, aws_subnet.main.*.id)}"
}
