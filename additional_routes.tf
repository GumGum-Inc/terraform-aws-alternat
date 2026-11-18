variable "additional_pod_nat_route_tables" {
  description = "Additional route tables keyed by AZ, with an existing route table whose default route supplies the initial NAT target. Include the additional tables in vpc_az_maps for alterNAT failover."
  type = map(object({
    existing   = string
    additional = string
  }))
  default = {}
}

variable "additional_pod_nat_ingress_cidrs" {
  description = "Additional IPv4 CIDRs allowed to reach NAT instances, in a separate security group rule."
  type        = list(string)
  default     = []
}

variable "additional_pod_nat_ingress_description" {
  description = "Description for the additional NAT ingress rule."
  type        = string
  default     = "Additional pod subnets"
}

data "aws_route_table" "existing_pod_nat" {
  for_each       = var.additional_pod_nat_route_tables
  route_table_id = each.value.existing
}

resource "aws_route" "additional_pod_nat" {
  for_each = var.additional_pod_nat_route_tables

  route_table_id         = each.value.additional
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = try(one([for route in data.aws_route_table.existing_pod_nat[each.key].routes : route.network_interface_id if route.cidr_block == "0.0.0.0/0" && route.network_interface_id != ""]), null)
  nat_gateway_id         = try(one([for route in data.aws_route_table.existing_pod_nat[each.key].routes : route.nat_gateway_id if route.cidr_block == "0.0.0.0/0" && route.nat_gateway_id != ""]), null)

  # alterNAT changes route targets during instance replacement and failover.
  lifecycle {
    ignore_changes = [network_interface_id, nat_gateway_id]
  }
}

moved {
  from = aws_security_group_rule.additional_pod_nat_ingress
  to   = aws_security_group_rule.additional_pod_nat_ingress[0]
}

resource "aws_security_group_rule" "additional_pod_nat_ingress" {
  count = length(var.additional_pod_nat_ingress_cidrs) > 0 ? 1 : 0

  type              = "ingress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = var.additional_pod_nat_ingress_cidrs
  security_group_id = aws_security_group.nat_instance.id
  description       = var.additional_pod_nat_ingress_description
}
