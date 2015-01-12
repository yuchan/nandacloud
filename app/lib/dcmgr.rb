require 'net/ssh'

class Dcmgr
    def initialize
    end

    def self.ssh_connect
      Net::SSH.start('192.168.33.21', 'vagrant', :password => "vagrant") do |ssh|
       ssh.exec "echo 'Hello'" 
      end
    end
end
