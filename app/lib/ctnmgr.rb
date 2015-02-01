require 'net/ssh'

class Ctnmgr
  attr_accessor :host, :name, :pass
  def initialize(host, name, pass)
    @host = host
    @name = name
    @pass = pass
  end

  def launch_vm(name)
    result = ""
    Net::SSH.start(@host, @name, :password => @pass) do |ssh|
      cmds = [
        "sudo /usr/local/go/bin/go run ./bin/nanda-lxc-clone.go --name ubuntu --newname #{name} --backend dir",
        "sudo /usr/local/go/bin/go run ./bin/nanda-lxc-start.go --name #{name}"
        ]

      ssh.exec!(makecommand(cmds)) do |channel, stream, data|
        result << data if stream == :stdout
        puts data
      end
    end
    {ip: result}
  end

  def stop_vm(name, path)
    Net::SSH.start(@host, @name, :password => @pass) do |ssh|
      ssh.exec makecommand(["sudo lxc-stop -n #{name}"]) do |ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
      end
    end
  end

  def remove_vm(name, path)
    Net::SSH.start(@host, @name, :password => @pass) do |ssh|
      ssh.exec makecommand(["sudo lxc-destroy -n #{name}"]) do |ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
      end
    end
  end

  private

  def makecommand(cmds)
    c = Array.new
    c.push "mkdir -p /home/#{@name}/golib"
    c.push "export GOROOT=/usr/local/go"
    c.push "export GOPATH=/home/#{@name}/golib"
    c.push "export PATH=$PATH:/usr/local/go/bin"

    cmds.each do |cmd|
        c.push cmd
    end
    c.join(" && ")
  end
end
