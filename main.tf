terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.0.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  for_each      = var.vm_settings
  name          = each.value.netportgroup
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "template_file" "userdata" {
  for_each = var.vm_settings
  template = file("${path.module}/templates/userdata.yaml")
  vars = {
    username       = each.value.user
    ssh_public_key = each.value.sshkey
    ip_address     = each.value.ip
    netmask        = each.value.subnet
    nameservers    = jsonencode(each.value.nameservers)
    gateway        = each.value.gw
  }
}
resource "vsphere_virtual_machine" "vms" {
  for_each         = var.vm_settings
  name             = each.key
  annotation       = "Deployed with Terraform"
  folder           = each.value.folder
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = each.value.cpus
  memory           = each.value.memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id   = data.vsphere_network.network[each.key].id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  }
  cdrom {
    client_device = true
  }

  disk {
    label            = "disk0"
    size             = each.value.disk
    thin_provisioned = each.value.thin
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

  }
  vapp {
    properties = {
      "instance-id" = each.key
      "hostname"    = each.key
      "user-data"   = base64encode(data.template_file.userdata[each.key].rendered)
      "public-keys" = each.value.sshkey
    }
  }
}