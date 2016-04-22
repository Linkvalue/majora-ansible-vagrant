# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'

VAGRANTFILE_API_VERSION = "2"

config_file = 'ansible/vars.yml';
if !File.exist?(config_file)
    abort("le fichier "+config_file+" n'existe pas")
end
settings = YAML.load_file config_file

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.define :local, primary: true do |local|

        # Ubuntu version
        local.vm.box = settings['image']['base_box_name']

        # VirtualBox configuration
        local.vm.provider "virtualbox" do |vb|
            vb.gui = settings['system']['gui']
            vb.cpus = settings['system']['cpus']
            vb.memory = settings['system']['memory']
            vb.customize ["modifyvm", :id, "--cpuexecutioncap", settings['system']['cpuexecutioncap']]

            vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
            vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
            vb.customize ["modifyvm", :id, "--usb", "off"]
            vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
        end

        # Network
        local.vm.hostname = "acme-project"
        local.vm.network "private_network", ip: "192.168.100.10"

        settings['share'].each { |synced_folder|
            config.vm.synced_folder synced_folder["src"],
            synced_folder["target"],
            type: synced_folder["type"],
            mount_options: [synced_folder["mount_options"]]
        }

        # Ansible provisionning
        local.vm.provision :ansible do |ansible|
            ansible.playbook = "ansible/app.yml"
            ansible.limit = "all"
            ansible.verbose = true
        end
    end
end
