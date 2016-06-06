# majora-ansible-vagrant

Vagrant implementation of [LinkValue/majora-ansible-playbook](https://github.com/LinkValue/majora-ansible-playbook).

This Vagrant boilerplate also shows how to add other roles in `ansible/galaxy-additionals.yml` in order to fulfill majora-ansible-playbook dependencies (such as `ruby`).



## Requirements

### Mac OS/X

* VirtualBox: https://www.virtualbox.org/wiki/Downloads
* VirtualBox Extension Pack: https://www.virtualbox.org/wiki/Downloads
* Vagrant: https://www.vagrantup.com/downloads.html
* Ansible: https://valdhaus.co/writings/ansible-mac-osx

### Ubuntu

* Check in computer BIOS that Virtualization/VT-d/VT-x are `Enabled/On`
* VirtualBox: https://www.virtualbox.org/wiki/Downloads
* VirtualBox Extension Pack: https://www.virtualbox.org/wiki/Downloads
* Vagrant: https://www.vagrantup.com/downloads.html
* Ansible: http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-apt-ubuntu
* NFS: `sudo apt-get install nfs-common nfs-kernel-server`



## Usage

### 1. Customize application

Download this repository (git clone or download zip tarball), then open and edit the following files the way you need:

  - `Vagrantfile` => virtual machine main configurations (memory/cpu usages, hostname, IP address and shared folder)
  - `app.yml` => every roles (mysql, redis, php, nginx, etc.)
  - `vars.yml` => every roles variables (versions, configurations, etc.)
  - `vars.local.yml` => every personal roles variables (php memory_limit, composer github token, oh-my-zsh theme, etc.)

If you don't have any clues about how you can customize the VM provisioning of your application, take a look at [Configuration recipes](#configuration-recipes).

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



## Configuration recipes

### Python project

#### app.yml

```yaml
# ...

  roles:
    - common-packages
    - oh-my-zsh
    - python

# ...
```

#### vars.yml

```yaml
python_versions: ['3.5']

pip_packages:
  - bottle
  - flask
```

### Multiple PHP projects

To handle multiple projects in a single VM, we create a folder `www` at the root of this repository.

The `www` folder contains 3 folders (each containing 1 PHP project sources) and will be shared with `/var/www` on the VM side.

Let's say the 3 PHP project folders are `sf-api` (Symfony project; run on PHP 7.0; depends on Redis), `OhMyZend` (Zend project; run on PHP 7.0; depends on MySQL) and `php56-site` (Framework-less project; run on PHP 5.6; depends on the 2 other projects).

And we want these PHP projects to be respectively accessible at `sf-api.dev`, `zend-api.dev` and `my-website.dev` (assuming you've set up your "hosts" file accordingly).

Here's the configuration you may use to run such a VM:

#### Vagrantfile

```ruby
# ...

        # Share folders
        local.vm.synced_folder "www", "/var/www/", id:"www-root", type: "nfs", mount_options: ["nolock,vers=3,udp,noatime,actimeo=1"]

# ...
```

#### app.yml

```yaml
# ...

  roles:
    - common-packages
    - etc-hosts
    - oh-my-zsh
    - nginx
    - php
    - composer
    - mysql
    - redis

# ...
```

#### vars.yml

```yaml
php_versions: ['7.0', '5.6']

zsh_additional_commands: >
  alias php-debug='phpdbg -qrr'
  alias sf='php bin/console'
  alias sf5='php5.6 bin/console'
  alias sf7='php7.0 bin/console'

mysql:
  users:
    - { name: 'root', password: '' }

sites:
  - { name: 'sf-api', server_name: 'sf-api.dev', template: 'vhost.symfony.j2' }
  - { name: 'zend-api', server_name: 'zend-api.dev', template: 'vhost.zend.j2' docroot: '/var/www/OhMyZend' }
  - { name: 'php56-site', server_name: 'my-website.dev', template: 'vhost.php.j2', fastcgi_pass: 'unix:/run/php/php5.6-fpm.sock' }

etc_hosts_lines:
  - { ip: '127.0.0.1', hostname: 'sf-api.dev zend-api.dev' } # because "php56-site" project will send HTTP requests to the 2 other projects
```
