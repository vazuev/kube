Vagrant.configure("2") do |config|

  # config.vm.synced_folder "ansible", "/ansible"
  # config.ssh.forward_agent = true
  config.vm.boot_timeout = 600
  config.disksize.size = '60GB'

  config.vm.define "control" do |d|
    d.vm.box = "ubuntu/bionic64"
    d.vm.hostname = "control"
    d.vm.synced_folder ".", "/vagrant", type: "virtualbox"
    d.vm.synced_folder "control", "/home/vagrant/src", type: "virtualbox"
    d.vm.network "private_network", ip: "192.168.111.10"
    d.vm.provision :shell, privileged:false, path: "bootstrap_ansible.sh"
    d.vm.provision :shell, inline: 'cat /vagrant/control.pub >> /home/vagrant/.ssh/authorized_keys'
    d.vm.provider "virtualbox" do |v|
      v.memory = 4096
    end
  end

  config.vm.define "node1" do |d|
    d.vm.box = "ubuntu/bionic64"
    d.vm.hostname = "node1"
    d.vm.network "private_network", ip: "192.168.111.11"
    d.vm.provision :shell, inline: 'cat /vagrant/control.pub >> /home/vagrant/.ssh/authorized_keys'
    d.vm.provider "virtualbox" do |v|
      v.memory = 2000
    end
  end

  config.vm.define "node2" do |d|
    d.vm.box = "ubuntu/bionic64"
    d.vm.hostname = "node2"
    d.vm.network "private_network", ip: "192.168.111.12"
    d.vm.provision :shell, inline: 'cat /vagrant/control.pub >> /home/vagrant/.ssh/authorized_keys'
    d.vm.provider "virtualbox" do |v|
      v.memory = 2000
    end
  end
  
  config.vm.define "node3" do |d|
    d.vm.box = "ubuntu/bionic64"
    d.vm.hostname = "node3"
    d.vm.network "private_network", ip: "192.168.111.13"
    d.vm.provision :shell, inline: 'cat /vagrant/control.pub >> /home/vagrant/.ssh/authorized_keys'
    d.vm.provider "virtualbox" do |v|
      v.memory = 2000
    end
  end

  config.vm.define "node4" do |d|
    d.vm.box = "ubuntu/bionic64"
    d.vm.hostname = "node4"
    d.vm.network "private_network", ip: "192.168.111.14"
    d.vm.provision :shell, inline: 'cat /vagrant/control.pub >> /home/vagrant/.ssh/authorized_keys'
    d.vm.provider "virtualbox" do |v|
      v.memory = 2000
    end
  end

end
