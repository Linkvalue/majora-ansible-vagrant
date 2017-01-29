# majora-ansible-vagrant

Vagrant implementation of [LinkValue/majora-ansible-playbook](https://github.com/LinkValue/majora-ansible-playbook).

This Vagrant boilerplate also shows how to add other Ansible roles in `ansible/galaxy-additionals.yml` in order to fulfill majora-ansible-playbook dependencies (such as `ruby`).



## Requirements

### Mac OS/X

* VirtualBox: https://www.virtualbox.org/wiki/Downloads
* VirtualBox Extension Pack: https://www.virtualbox.org/wiki/Downloads
* Vagrant (>= 1.8.4): https://www.vagrantup.com/downloads.html
* Host manager: `vagrant plugin install vagrant-hostmanager`

### Ubuntu

* Check in computer BIOS that Virtualization/VT-d/VT-x are `Enabled/On`
* VirtualBox: https://www.virtualbox.org/wiki/Downloads
* VirtualBox Extension Pack: https://www.virtualbox.org/wiki/Downloads
* Vagrant (>= 1.8.4): https://www.vagrantup.com/downloads.html
* NFS: `sudo apt-get install nfs-common nfs-kernel-server`
* Host manager: `vagrant plugin install vagrant-hostmanager`

### Windows

* Check that "Hyper-V" is disabled (it is enabled by default on Windows 8 and 10 Pro)
* VirtualBox: https://www.virtualbox.org/wiki/Downloads
* VirtualBox Extension Pack: https://www.virtualbox.org/wiki/Downloads
* Vagrant (>= 1.8.4): https://www.vagrantup.com/downloads.html
* NFS: `vagrant plugin install vagrant-winnfsd`
* Make: http://gnuwin32.sourceforge.net/downlinks/make.php (don't forget to include it in your `PATH` env variable)
* Host manager: `vagrant plugin install vagrant-hostmanager`



## Usage

### 1. Configure the VM according to the applications it will host

Download this repository (download zip or `git clone`), then open and edit the following files the way you need:

  - `ansible/vagrant-parameters.yml` => main Vagrant parameters that shouldn't be changed by other users (sharing strategy, hosts to bind with VM IP, etc.)
  - `ansible/vagrant-parameters.local.yml.dist` => default values for personal Vagrant parameters (RAM and CPU usage, VM IP, forwarded files, etc.)
  - `ansible/app.yml` => every Ansible roles (common-packages, oh-my-zsh, mysql, php, nginx, redis, nodejs, etc.)
  - `ansible/vars.yml` => every Ansible roles variables (mysql users, php versions, nginx virtual hosts, shell aliases, etc.)
  - `ansible/vars.local.yml.dist` => default values for every personal roles variables (php memory_limit, composer github token, oh-my-zsh theme, etc.)

Note: "*.dist" files are only templates to hold default values (i.e. what you think is good enough for everyone). Each of these will be duplicated as a "gitignored file" to let everyone apply their own customization.

If you don't have any clue about how you can customize the VM provisioning of your application, take a look at [Configuration recipes](#configuration-recipes).

### 2. Provision virtual machine

```bash
make provision
```

### 3. SSH to virtual machine

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

# Provision virtual machine
make provision

# Rebuild virtual machine
make rebuild

# Destroy (free disk space)
make destroy
```



## Sharing strategies

majora-ansible-vagrant offers 2 different ways of sharing your projects sources with the VM using NFS.

The strategy to use should be defined in the `ansible/vagrant-parameters.yml` file.

### `self` strategy (default sharing strategy)

If you want to host a single project in your VM and you want to commit it in this project (e.g. to share your development environment with others), the `sharing_strategy: 'self'` is exactly what you want.

This will share this project root directory, so you'll just have to add the `ansible` directory, the `Vagrantfile`, the `Makefile` and the `.gitignore` file content in your own project root directory.

By default, it mounts your root directory in `/var/www/majora-ansible-vagrant` on the VM side, so don't forget to edit the `vagrant-parameters.yml` file to change the `sharing_self_absolute_path_in_vm` value in order to mount your project sources in a more appropriate location.

Behind the scene, this is what will be included in the `Vagrantfile` (by default):

```
vm.synced_folder '.', '/var/www/majora-ansible-vagrant' ...
```

### `subdirectory` strategy

If you want to host several projects in a single VM (e.g. to leverage the memory/CPU/disk cost of running multiple VMs or to ease the communication between these projects) or if you just don't want to include your development environment in your projects, the `sharing_strategy: 'subdirectory'` is exactly what you want.

This will share a single subdirectory (usually named `www` because usually mounted as `/var/www` on the VM side) where you'll put all your projects sources.

Don't forget to edit the `.gitignore` file to ignore the `www` folder as you probably don't want to commit it along your VM.

Behind the scene, this is what will be included in your `Vagrantfile` (by default):

```
vm.synced_folder 'www', '/var/www' ...
```



## Configuration recipes

### Multiple PHP projects

To handle multiple projects in a single VM, we create a folder `www` at the root of this repository.

The `www` folder contains 3 folders (each containing 1 PHP project sources) and will be shared with `/var/www` on the VM side.

Let's say the 3 PHP project folders are `sf-api` (Symfony project; run on PHP 7.0; depends on Redis), `OhMyZend` (Zend project; run on PHP 7.0; depends on MySQL) and `php56-site` (Framework-less project; run on PHP 5.6; depends on the 2 other projects).

And we want these PHP projects to be respectively accessible at `sf-api.dev`, `zend-api.dev` and `my-website.dev` (assuming you've set up your "hosts" file accordingly).

Here's the configuration you may use to run such a VM:

#### vagrant-parameters.yml

```yaml
# ...

sharing_strategy: 'subdirectory'

sharing_subdirectory_relative_path: 'www'

sharing_subdirectory_absolute_path_in_vm: '/var/www'

# ...
```

#### app.yml

```yaml
# ...

  roles:
    - common-packages
    - oh-my-zsh
    - etc-hosts
    - nginx
    - php
    - composer
    - mysql
    - redis

# ...
```

#### vars.yml

```yaml
php_versions: ['7.0', '5.6'] # main php version will be 7.0 because it's the first value

zsh_additional_commands: |
  alias php-debug='phpdbg -qrr'
  alias sf='php bin/console'
  alias sf5='php5.6 bin/console'
  alias sf7='php7.0 bin/console'

mysql:
  users:
    - { name: 'root', password: '' }

sites:
  - { name: 'sf-api', server_name: 'sf-api.dev', template: 'vhost.symfony.j2' }
  - { name: 'zend-api', server_name: 'zend-api.dev', template: 'vhost.zend.j2', docroot: '/var/www/OhMyZend' }
  - { name: 'php56-site', server_name: 'my-website.dev', template: 'vhost.php.j2', fastcgi_pass: 'unix:/run/php/php5.6-fpm.sock' }

etc_hosts_lines:
  - { ip: '127.0.0.1', hostname: 'sf-api.dev zend-api.dev' } # because "php56-site" project will send HTTP requests to the 2 other projects
```

### Single PHP/MySQL project

#### vagrant-parameters.yml

```yaml
# ...

sharing_strategy: 'self'

sharing_self_absolute_path_in_vm: '/var/www/my-symfony-project'

# ...
```

#### app.yml

```yaml
# ...

  roles:
    - common-packages
    - oh-my-zsh
    - nginx
    - php
    - composer
    - mysql

# ...
```

#### vars.yml

```yaml
php_versions: ['7.0']

sites:
  - { name: 'my-symfony-project', server_name: 'symfony.dev', template: 'vhost.symfony.j2' }

zsh_additional_commands: |
  alias sf='php bin/console'

mysql:
  users:
    - { name: 'root', password: '' }
```

### Single Python project

#### vagrant-parameters.yml

```yaml
# ...

sharing_strategy: 'self'

sharing_self_absolute_path_in_vm: '/var/www/my-python-project'

# ...
```

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
