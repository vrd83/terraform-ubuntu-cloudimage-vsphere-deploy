variable "vsphere_server" {
  type        = string
  description = "vCenter Server FQDN or IP"
}

variable "vsphere_user" {
  type        = string
  description = "vSphere username"
  default     = "administrator@vsphere.local"
}

variable "vsphere_password" {
  type        = string
  description = "vSphere password"
}

variable "vsphere_datacenter" {
  type        = string
  description = "vCenter Datacenter to deploy in to"
}

variable "vsphere_datastore" {
  type        = string
  description = "vCenter datastore to deploy in to"
}

variable "vsphere_cluster" {
  type        = string
  description = "vCenter cluster to deploy in to"
}

variable "vsphere_template_name" {
  type        = string
  description = "vCenter VM template to use"
}

variable "vm_settings" {
  description = "Map of virtual machine settings"
  type        = map(any)
  default     = {}
}

