# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  # Enable this if the provider is virtualbox
  #config.vm.provider "virtualbox" do |vb|  
  #   vb.memory = "1024"
  #end
  
  config.vm.provision "shell", path: "setup.sh"

end
