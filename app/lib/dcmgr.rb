require 'net/ssh'
require 'digest/sha1'

# KVM Version

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

  def launch_vm(name, nodepath, metadata, publickey, new_ip, host_ip)
    dcnode = "#{@name}@#{host_ip}"
    cmds = [
      'mkdir -p ~/md_mount',
      "echo -e \"DEVICE=eth0\\nTYPE=Ethernet\\nONBOOT=yes\\nNM_CONTROLLED=yes\\nBOOTPROTO=static\\nIPADDR=#{new_ip}\" | sudo tee ~/md_mount/ifcfg-eth0",
      "sudo echo #{publickey} > md_mount/pub.pub",
      'sync',
      "scp #{metadata} #{dcnode}:~/vm/#{name}.img.metadata",
      "scp #{nodepath} #{dcnode}:~/vm/#{name}.img",
    ]
    system(cmds.join(' && '))
    Net::SSH.start(host_ip, @name, password: @pass) do |ssh|
      cmds = [
        "sudo virt-install --name #{name} --ram 512 --disk ~/vm/#{name}.img,format=qcow2 --disk ~/vm/#{name}.img.metadata --network bridge=br0 --vnc --noautoconsole --import"
      ]
      ssh.exec cmds.join(' && ') do |_ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
      end
    end
  end

  def start_vm(name)
    Net::SSH.start(@host, @name, password: @pass) do |ssh|
      cmd = "sudo virsh start #{name}"
      ssh.exec cmd do |_ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
      end
    end
  end

  def stop_vm(name)
    Net::SSH.start(@host, @name, password: @pass) do |ssh|
      cmd = "sudo virsh destroy #{name}"
      ssh.exec cmd do |_ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
      end
    end
  end

  def remove_vm(name)
    Net::SSH.start(@host, @name, password: @pass) do |ssh|
      cmd = "sudo virsh destroy #{name} ; sudo virsh undefine #{name} && sudo rm -f /home/dcnode/vm/#{name}.img && sudo rm -f /home/dcnode/vm/#{name}.img.metadata"
      ssh.exec cmd do |ch, stream, data|
        if stream == :stderr then
          puts "ERROR: #{data}"
        end
      end
    end
  end

  def self.generate_key()
    key = {}
    filename = Digest::SHA1.hexdigest('nandacloud' + Time.now.to_s)
    comment = 'comment'
    path = '/tmp/'
    cmd = "ssh-keygen -q -t rsa -C '#{comment}' -N '' -f '#{path}#{filename}' >/dev/null && openssl rsa -in #{path}#{filename} -outform pem > #{path}#{filename}.pem "

    system(cmd)
    result = ''
    f = open("#{path}#{filename}.pub", 'r')
    f.each do |line|
      result += line
    end

    f.close
    key[:result] = result
    key[:name] = filename
    key
  end

  def self.remove_key(name)
    path = "/tmp/#{name}"
    cmd = "rm -f #{path}.pub #{path}.pem"
    system(cmd)
  end
end
