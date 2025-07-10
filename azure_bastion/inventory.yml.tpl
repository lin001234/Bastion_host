all:
  children:
    azure_vms:
      hosts:
        ${instance_name}:
          ansible_host: ${instance_ip}
      vars:
        ansible_ssh_user: ${ansible_user}
        ansible_ssh_private_key_file: ${instance_key}
