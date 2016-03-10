# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# Get ssh conf
current_dir = File.dirname(File.expand_path(__FILE__))
configs = YAML.load_file("#{current_dir}/ansible/vars.local.yml")
ssh_host_folder = configs['ssh_host_folder']
ssh_folder = configs['ssh_folder']

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.define :local, primary: true do |local|

        # Ubuntu version
        local.vm.box = "ubuntu/trusty64"

        # VirtualBox configuration
        local.vm.provider "virtualbox" do |vb|
            vb.customize ["modifyvm", :id, "--memory", 2048, "--cpus", "2"]
            vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
            vb.customize ["modifyvm", :id, "--usb", "off"]
            vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
        end

        # Network
        local.vm.hostname = "acme-project"
        local.vm.network "private_network", ip: "192.168.100.10"

        # Share folders
        local.vm.synced_folder ".", "/var/www/AcmeProject/", id:"project-root", type: "nfs", mount_options: ["nolock,vers=3,udp,noatime,actimeo=1"]

        # Share ssh
        local.vm.provision "file", source: ssh_host_folder, destination: ssh_folder

        # Get git
        local.vm.provision "shell", inline: "apt-get install git -y"

        # Ansible provisionning
        local.vm.provision "ansible_local" do |ansible|
            ansible.playbook = "ansible/app.yml"
            ansible.install = true
            ansible.version = "latest"
            ansible.verbose = true
            ansible.limit = "all"
            ansible.provisioning_path = "/var/www/AcmeProject/"
            ansible.galaxy_command = "ansible-galaxy install --force -p /var/www/AcmeProject/ansible --role-file=/var/www/AcmeProject/ansible/galaxy-majora.yml && ansible-galaxy install --force -p /var/www/AcmeProject/ansible/roles --role-file=/var/www/AcmeProject/ansible/galaxy-additionals.yml"
            # This is required to launch ansible-galaxy command
            # Perhaps not anymore on vagrant 1.8.2
            ansible.galaxy_role_file = "a"
        end

    end

end
