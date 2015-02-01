require 'net/ssh'

class Ctnmgr
  attr_accessor :host, :name, :pass
  def initialize(host, name, pass)
    @host = host
    @name = name
    @pass = pass
  end

  def launch_vm(name)
    Net::SSH.start(@host, @name, :password => @pass) do |ssh|
      cmds = [
        "sudo lxc-clone ubuntu #{name}",
        "sudo lxc-start -n #{name} -d"
        ]
      ssh.exec cmds.join(" && ") do |ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
      end
    end
  end

  def remove_vm(name, path)
    Net::SSH.start(@host, @name, :password => @pass) do |ssh|
      cmd = "sudo lxc-stop -n #{name}"
      ssh.exec cmd do |ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
      end
    end
  end
end
