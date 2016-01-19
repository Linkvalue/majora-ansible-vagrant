.PHONY: download provision start stop ssh destroy rebuild

#
# Main targets
#
download: vm-download
provision: vm-provision
start: vm-up
stop: vm-halt
ssh: vm-ssh
destroy: vm-destroy
rebuild: vm-rebuild

#
# VM
#
vm-download:
	test -f ansible/vars.local.yml || cp ansible/vars.local.yml.dist ansible/vars.local.yml
	ansible-galaxy install --force --role-file=requirements.yml

vm-ssh:
	vagrant ssh

vm-up:
	vagrant up

vm-halt:
	vagrant halt

vm-provision:
	vagrant up --no-provision
	vagrant provision

vm-destroy:
	vagrant destroy

vm-rebuild: vm-destroy vm-provision
