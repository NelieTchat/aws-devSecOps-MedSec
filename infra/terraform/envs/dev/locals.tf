locals {
  # Short name used in alarms & dashboard names
  name = "medsec-dev"

  # Standard tags for all resources in this env
  common_tags = {
    Project = "medsec"
    Env     = "dev"
    Owner   = "platform"
  }
}
