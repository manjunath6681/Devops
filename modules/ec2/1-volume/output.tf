output "instance_ids_out" {
    value = ["${aws_instance.instance.*.id}"]
}
