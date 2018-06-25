# Openstack
variable "os_user" {}

variable "os_pass" {}

variable "tenant" {
  default = "sweng-dev"
}

variable "os_auth_url" {}

# Images
variable "ubuntu_18" {
  default = "c5428b67-5835-42a2-bca1-933898e099a3"
}

# Flavors
variable "medium" {
  default = "87124402-d013-4269-85f0-b887f24c6506"
}

variable "small" {
  default = "5f5b0ab4-1d87-40cc-8165-d3635bf0ee0c"
}
