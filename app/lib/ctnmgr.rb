require 'net/ssh'

# LXC Version

class Ctnmgr
  attr_accessor :host, :name, :pass
  def initialize(host, name, pass)
    @host = host
    @name = name
    @pass = pass
  end

  def launch_vm(name)
    result = ''
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
    { ip: result }
  end

  def start_vm(name)
    Net::SSH.start(@host, @name, :password => @pass) do |ssh|
      ssh.exec makecommand(["sudo lxc-start -n #{name} -d"]) do |ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
      end
    end
  end

  def stop_vm(name)
    Net::SSH.start(@host, @name, :password => @pass) do |ssh|
      ssh.exec makecommand(["sudo lxc-stop -n #{name}"]) do |ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
      end
    end
  end

  def destroy_vm(name)
    Net::SSH.start(@host, @name, :password => @pass) do |ssh|
      ssh.exec makecommand(["sudo lxc-destroy -n #{name}"]) do |ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        end
      end
    end
  end

  def generate_key()
    key = {}
    result = ""
    filename = ""
    Net::SSH.start(@host, @name, :password => @pass) do |ssh|
      filename = Digest::SHA1.hexdigest ('nandacloud' + Time.now.to_s)
      comment = 'comment'
      cmd = "ssh-keygen -q -t rsa -C '%s' -N '' -f %s >/dev/null && cat #{filename}.pub >> ~/.ssh/authorized_keys && cat #{filename}" %
             [comment, filename]

      ssh.exec cmd do |_ch, stream, data|
        if stream == :stderr
          puts "ERROR: #{data}"
        else
          puts data
          result = data
        end
      end
    end
    key[:result] = result
    key[:name] = filename
    key
  end

  private

  def makecommand(cmds)
    c = []
    c.push 'mkdir -p /home/#{@name}/golib'
    c.push 'export GOROOT=/usr/local/go'
    c.push 'export GOPATH=/home/#{@name}/golib'
    c.push 'export PATH=$PATH:/usr/local/go/bin'

    cmds.each do |cmd|
      c.push cmd
    end
    c.join(' && ')
  end
end
