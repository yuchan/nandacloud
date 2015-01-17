VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "chef/centos-7.0"

  config.vm.define :dcmgr do | dcmgr |
    dcmgr.vm.hostname = "dcmgr"
    dcmgr.vm.network :private_network, ip: "192.168.33.20"
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
      dcnode.vm.hostname = "dcmem1"
      dcnode.vm.network :private_network, ip: value
    
      #config.vm.provisionのブロック
      dcnode.vm.provision 'chef_solo' do | chef |
        chef.cookbooks_path = ["./chef/cookbooks", "./chef/site-cookbooks"]
        chef.roles_path = "./chef/roles"
        chef.data_bags_path = "./chef/data_bags"
        chef.run_list = [
          "recipe[kvm]",
          "recipe[kvm::host]"
        ]
      end
    end
  end
  
#  config.vm.define :dcmem2 do | dcmem2 |
#    dcmem2.vm.hostname = "dcmem2"
#    dcmem2.vm.network :private_network, ip: "192.168.33.22"
#  end
#
#  config.vm.define :dcmem3 do | dcmem3 |
#    dcmem3.vm.hostname = "dcmem3"
#    dcmem3.vm.network :private_network, ip: "192.168.33.23"
#  end
end
