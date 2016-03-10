# majora-ansible-vagrant

Vagrant implementation of [LinkValue/majora-ansible-playbook](https://github.com/LinkValue/majora-ansible-playbook).

This Vagrant boilerplate also shows how to add other roles in `ansible/galaxy-additionals.yml` in order to fulfill majora-ansible-playbook dependencies (such as `ruby`).

 * You need to patch vagrant before using this, (with vagrant < 1.8.2) : https://github.com/mitchellh/vagrant/commit/9dbdb9397a92d4fc489e9afcb022621df7f60d11
 * Vagrant destroy command works only if vagrant is not  running. Use vagrant suspend before destroying.

## Requirements

### Mac OS/X

* VirtualBox: https://www.virtualbox.org/wiki/Downloads
* VirtualBox Extension Pack: https://www.virtualbox.org/wiki/Downloads
* Vagrant: http://www.vagrantup.com/downloads
* Ansible: https://valdhaus.co/writings/ansible-mac-osx

### Ubuntu

* Check in computer BIOS that Virtualization/VT-d/VT-x are `Enabled/On`
* VirtualBox: https://www.virtualbox.org/wiki/Downloads
* VirtualBox Extension Pack: https://www.virtualbox.org/wiki/Downloads
* Vagrant: http://www.vagrantup.com/downloads
* Ansible: http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-apt-ubuntu
* NFS: `sudo apt-get install nfs-common nfs-kernel-server`

### Windows
* VirtualBox: https://www.virtualbox.org/wiki/Downloads
* VirtualBox Extension Pack: https://www.virtualbox.org/wiki/Downloads
* Vagrant: http://www.vagrantup.com/downloads
* NFS : install vagrant plugin : https://github.com/winnfsd/vagrant-winnfsd
* Change the ssh folder in vars.local.yml

## Usage

### 1. Customize application

Download this repository (git clone or download zip tarball), then open and edit the following files the way you need:

  - `Vagrantfile` => virtual machine main configurations (ubuntu version, memory/cpu usages, hostname, IP and shared folder)
  - `app.yml` => every roles (mysql, redis, php, nginx, etc.)
  - `vars.yml` => every roles variables (versions, configurations, etc.)
  - `vars.local.yml` => every personal roles variables (composer github token, oh-my-zsh theme, etc.)

### 2. Download Ansible roles

```bash
make download
```

### 3. Provision virtual machine

```bash
make provision
```

### 4. SSH to virtual machine

```bash
make ssh
```



## Makefile reminder

```bash
# Start virtual machine
make start

# Stop virtual machine (free memory/cpu usages)
make stop

# SSH to virtual machine
make ssh

# Download ansible roles (will override existing roles with latests)
make download

# Provision virtual machine
make provision

# Rebuild virtual machine
make rebuild

# Destroy (free disk space)
make destroy
```
