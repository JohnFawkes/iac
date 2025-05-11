resource "proxmox_virtual_environment_vm" "semaphore" {

    # VM General Settings
    node_name    = "pve2"
    name         = "semaphore"
    description  = "Webui for Ansible and Tofu"
    tags         = ["tofu", "ubuntu25", "ansible", "packer"]

    agent {
      enabled = true
    }

    clone {
        vm_id = 19001
    }
    
    # VM CPU Settings
    cpu {
        cores = 2
        type  = "host"
        architecture = "x86_64"
    }
    
    # VM Memory Settings
    memory {
        dedicated = 2048
    }

    # VM Network Settings
    network_device {
        bridge  = "vmbr0"
        vlan_id = 1
    }

    # VM Disk Settings
    disk {
        datastore_id = "Fast500Gb"
        size         = 30
        interface    = "scsi0"
    }

    vga {
        type = "serial0"
    }

    initialization {
        ip_config {
            ipv4 {
                address = "10.69.69.3/24"
                gateway = "10.69.69.1"
            }
        }

        user_data_file_id = proxmox_virtual_environment_file.cloud_config_shared.id
    }

    lifecycle {
        ignore_changes = [
            initialization[0].user_account[0].keys,
            initialization[0].user_account[0].password,
            initialization[0].user_account[0].username,
            initialization[0].user_data_file_id
        ]
    }

}