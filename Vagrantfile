# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  # Bento are one of the Vagrant recommended boxes see
  # https://www.vagrantup.com/docs/boxes.html#official-boxes
  # https://app.vagrantup.com/bento
  #config.vm.box = "bento/debian-11"
  config.vm.box = "debian/bookworm64"
  #config.vm.box_version = "12.20231211.1"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 80, host: 8088
  config.vm.network "forwarded_port", guest: 5173, host: 8080
  config.vm.network "forwarded_port", guest: 4173, host: 8081

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # View the documentation for the provider you are using (VirtualBox)
  # for more information on available options.
  config.vm.provider "virtualbox" do |v|
    v.name = "Coordinate Converter 2-Vagrant"
    # Customize the amount of memory on the VM:
    v.memory = "2048"
    # Whether to use a master VM and linked clones
    v.linked_clone = false
  end

  config.vm.provision :shell, path: "provisioning/bootstrap.sh"
  config.vm.provision :shell, path: "provisioning/bootconfig.sh", run: "always"

end
