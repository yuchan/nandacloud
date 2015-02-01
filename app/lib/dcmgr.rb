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
    nodepath = "./vm/#{name}" #TODO path definition algorythm
    path = nodepath + "/centos"
    Net::SSH.start(@host, @name, :password => @pass) do |ssh|
      cmds = ["mkdir -p #{nodepath}",
              "cd #{nodepath}",
              "qemu-img create centos 8G",
              "virt-install --graphics vnc,listen=0.0.0.0 --noautoconsole --name #{name} --ram 512 --disk centos,size=8 --location 'http://ftp.iij.ad.jp/pub/linux/centos/7/os/x86_64/'"]
      ssh.exec cmds.join(" && ") do |ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
      end
    end
    {:instance_path => path}
  end

  def remove_vm(name, path)
    Net::SSH.start(@host, @name, :password => @pass) do |ssh|
      cmd = "virsh destroy #{name} && rm -rf #{path}"
      ssh.exec cmd do |ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
      end
    end
  end

  def generate_key(name)
    key = Hash.new
    Net::SSH.start(@host, @name, :password => @pass) do |ssh|
      filename = name 
      comment = "comment"
      cmd = "ssh-keygen -q -t rsa -C '%s' -N '' -f %s >/dev/null && cat #{filename}.pub >> ~/.ssh/authorized_keys" %
             [comment, filename]

      ssh.exec cmd do |ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
        result = ""
        f = open(filename + ".pub", 'r')
        f.each {|line| result += line}
        f.close
        key[:result] = result
        key[:name] = filename
      end
    end
    key
  end
end
