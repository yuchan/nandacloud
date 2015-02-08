VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :dcmgr do | dcmgr |
    dcmgr.vm.box = "hashicorp/precise64"
    dcmgr.vm.hostname = "dcmgr"
    dcmgr.vm.network :private_network, ip: "192.168.33.20"
    dcmgr.vm.synced_folder "app/", "/srv/app"
    dcmgr.vm.provision 'chef_solo' do | chef |
      chef.cookbooks_path = ["./chef/cookbooks", "./chef/site-cookbooks"]
      chef.roles_path = "./chef/roles"
      chef.data_bags_path = "./chef/data_bags"
      chef.add_recipe 'git'
      chef.add_recipe 'sqlite'
      chef.add_recipe 'base'
   end
  end

  nodes = {
    :dcnode1 => "192.168.33.21"
  }

  nodes.each do |key, value|
    config.vm.define key do | dcnode |
      dcnode.vm.box = "hashicorp/precise64"
      dcnode.vm.hostname = key
      dcnode.vm.network :private_network, ip: value

      #config.vm.provisionのブロック
      dcnode.vm.provision 'chef_solo' do | chef |
        chef.cookbooks_path = ["./chef/cookbooks", "./chef/site-cookbooks"]
        chef.roles_path = "./chef/roles"
        chef.data_bags_path = "./chef/data_bags"
        chef.add_recipe 'kvm'
        chef.add_recipe 'kvm::host'
        chef.add_recipe 'virtnode'
      end
    end
  end

  lxc_nodes = {
    :dcnodelxc1 => "192.168.33.25"
  }

  lxc_nodes.each do |key, value|
    config.vm.define key do | dcnode |
      dcnode.vm.box = "ubuntu/trusty64"
      dcnode.vm.hostname = key
      dcnode.vm.network :private_network, ip: value

      #config.vm.provisionのブロック
      dcnode.vm.provision 'chef_solo' do | chef |
        chef.cookbooks_path = ["./chef/cookbooks", "./chef/site-cookbooks"]
        chef.roles_path = "./chef/roles"
        chef.data_bags_path = "./chef/data_bags"
        chef.add_recipe 'lxc'
        chef.add_recipe 'golang'
      end
    end
  end

  config.omnibus.chef_version = :latest
end
