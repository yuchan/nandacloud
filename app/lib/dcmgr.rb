require 'net/ssh'

class Dcmgr
    attr_accessor :host, :name, :pass
    def initialize(host, name, pass)
      @host = host
      @name = name
      @pass = pass
    end

    def self.ssh_connect(host, name, pass)
      Net::SSH.start(host, name, :password => pass) do |ssh|
       ssh.exec "echo 'Hello'" 
      end
    end

    def launch_vm(name)
      Net::SSH.start(@host, @name, :password => @pass) do |ssh|
        ssh.exec "virt-install --force --name #{name} --graphics vnc,listen=0.0.0.0,port=5900 --ram 512 --disk ./centos,size=8 --location 'http://ftp.iij.ad.jp/pub/linux/centos/7/os/x86_64/'"
      end
    end
end

