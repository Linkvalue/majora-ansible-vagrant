.PHONY: help provision start stop ssh destroy rebuild

# Default target
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

#
# Virtual Machine targets
#
provision: vm-provision ## 
vm-provision: ## Start and provision the virtual machine (it runs the Ansible roles defined in ansible/app.yml file)
	vagrant up --no-provision
	vagrant provision

ssh: vm-ssh ## 
vm-ssh: ## Connect to virtual machine using SSH (requires the virtual machine to be started)
	vagrant ssh

stop: vm-halt ## 
vm-halt: ## Stop the virtual machine (free memory/cpu usages)
	vagrant halt

start: vm-up ## 
vm-up: ## Start the virtual machine (required to connect to it)
	vagrant up

destroy: vm-destroy ## 
vm-destroy: ## Destroy the virtual machine (free disk space usage)
	vagrant destroy

rebuild: vm-rebuild ## 
vm-rebuild: vm-destroy vm-provision ## Destroy the virtual machine before provisioning it
