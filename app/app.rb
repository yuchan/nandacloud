require 'bundler'
Bundler.require
require 'json'
require './model/instance'
require './model/sshkey'
require './lib/dcmgr'
require './lib/ctnmgr'

config_file 'config.yml'

# Common
class CommonUtil
  def self.sshkeygenerate
    info = Dcmgr.generate_key
    Sshkey.create(
      name: info[:name],
      public_key: info[:result],
      created: Time.now,
      updated: Time.now
    )
    info
  end

  def self.sshkeyremove(id)
    @sshkey = Sshkey[id]
    if @sshkey
      Dcmgr.remove_key(name)
      @sshkey.delete
      true
    else
      false
      { status: 'no sshkey' }.to_json
    end
  end

  def self.createinstance(instance_name, public_key, metadata_dir, start_ip, end_ip, host_ips, user, pass)
    success = ''
    message = ''
    @instance = Instance[name: instance_name]
    if @instance
      success = 'ok'
      message =  'The name of instance you entered was already used!'
    else
      @ip_list = Instance.select_map(:guest_ip)
      new_guest_ip = ''
      fips = start_ip
      eips = end_ip
      (fips[-1].to_i..eips[-1].to_i).each do |myhost|
        if @ip_list.include?("#{fips[0]}.#{fips[1]}.#{fips[2]}.#{myhost}") == false
          new_guest_ip = "#{eips[0]}.#{eips[1]}.#{eips[2]}.#{myhost}"
        end
      end

      if new_guest_ip == ''
        success = 'ng'
        message = 'Sorry, IP address is exhausted.'
      else
        @host_ip_list = {}
        puts host_ips
        host_ips.each do |node|
          @host_ip_list[node] = 0
        end
        @using_hosts = Instance.select_map(:host_ip)
        @using_hosts.each do |ip|
          @host_ip_list[ip] += 1
        end
        min = -1
        host_ip = ''
        @host_ip_list.each do |k, v|
          if  min > v || min == -1
            min = v
            host_ip = k
          end
        end

        Instance.create(
          name: instance_name,
          host_ip: host_ip,
          guest_ip: new_guest_ip,
          instance_path: '',
          created: Time.now,
          updated: Time.now
        )

        dm = Dcmgr.new(host_ip, user, pass)
        nodepath = '~/SeedInstances/centos.img'
        dm.launch_vm(instance_name, nodepath, metadata_dir, public_key, new_guest_ip, host_ip)
        name = instance_name
        success = 'ok'
        message = "The #{name} instance was created successfully.<br>You can access nanda@#{new_guest_ip} via your ssh console window by using the ssh-keypair file."
      end
    end

    result = {
      status: success,
      message: message
    }
    result
  end

  def self.startinstance(instance_name, user, pass)
    success = ''
    message = ''
    @instance = Instance[name: instance_name]
    if @instance
      dm = Dcmgr.new(@instance[:host_ip], user, pass)
      dm.start_vm(@instance.name)
      success = 'ok'
      message = "instance #{instance_name} started."
    else
      success = 'ng'
      message = 'Couldn\'t find instance name.'
    end

    result = {
      status: success,
      message: message
    }
    result
  end

  def self.stopinstance(instance_name, user, pass)
    success = ''
    message = ''
    @instance = Instance[name: instance_name]
    if @instance
      dm = Dcmgr.new(@instance[:host_ip], user, pass)
      dm.start_vm(@instance.name)
      success = 'ok'
      message = "instance #{instance_name} started."
    else
      success = 'ng'
      message = 'Couldn\'t find instance name.'
    end
    result = {
      status: success,
      message: message
    }
    result
  end

  def self.deleteinstance(instance_name, user, pass)
    success = ''
    message = ''
    @instance = Instance[name: instance_name]
    if @instance
      dm = Dcmgr.new(@instance[:host_ip], user, pass)
      dm.remove_vm(@instance.name)
      @instance.delete
    end

    success = 'ok'
    message = 'deleted successfully'

    result = {
      status: success,
      message: message
    }
    result
  end
end

=begin
 GUI Console
=end

get '/' do
  haml :index, locals: {
    message: ''
  }
end

get '/instances' do
  @message = ''
  @start_ip = settings.iprange_start
  @end_ip = settings.iprange_end
  @instances = Instance.all
  @sshkeys = Sshkey.all
  haml :instances, locals: {
    message: '',
    instances: @instances,
    sshkeys: @sshkeys,
    start_ip: settings.iprange_start,
    end_ip: settings.iprange_end
  }
end

post '/instances' do
  message = ''

  if params[:operation] == 'create'
    puts params[:keypair]
    @sshkey = Sshkey[params[:keypair]]
    result = CommonUtil.createinstance(params[:name], @sshkey.public_key, settings.metadata_dir, settings.iprange_start.split('.'), settings.iprange_end.split('.'), settings.nodes, settings.user, settings.pass)
  elsif params[:operation] == 'start'
    result = CommonUtil.startinstance(params[:name], settings.user, settings.pass)
  elsif params[:operation] == "stop"
    result = CommonUtil.stopinstance(params[:name], settings.user, settings.pass)
  end

  @instances = Instance.all
  @sshkeys = Sshkey.all
  haml :instances, locals: {
    message: result[:message],
    instances: @instances,
    sshkeys: @sshkeys,
    start_ip: settings.iprange_start,
    end_ip: settings.iprange_end
  }
end

delete '/instances' do
  CommonUtil.deleteinstance(params[:name], settings.user, settings.pass)
  redirect to('/instances')
end

get '/sshkeys' do
  @keys = Sshkey.all
  haml :sshkeys, locals: {
    message: '',
    keys: @keys
  }
end

post '/sshkeys' do
  info = CommonUtil.sshkeygenerate
  # Use services like S3 or cloudfront in the future??
  send_file "/tmp/#{info[:name]}.pem", filename: "#{info[:name]}.pem", disposition: :attachment
end

=begin
  JSON api
=end

post '/api/testssh' do
  Dcmgr.ssh_connect
  { status: 'ssh connected' }.to_json
end

#Instance API

get '/api/instances/:id' do
  @instance = Instance[params[:id]]
  if @instance.nil?
    { status: 'no instance' }.to_json
  else
    @instance.to_json
  end
end

get '/api/instances' do
  Instance.to_json
end

post '/api/instances/:name/:keypair' do
  @sshkey = Sshkey[params[:keypair]]
  result = CommonUtil.createinstance(params[:name], @sshkey.public_key, settings.metadata_dir, settings.iprange_start.split('.'), settings.iprange_end.split('.'), settings.nodes)
  result.to_json
end

delete '/api/instances/:id' do
  @instance = Instance[params[:id]]
  result = CommonUtil.deleteinstance(@instance.name, settings.user, settings.pass)
  result.to_json
end

put '/api/instances/:id' do
  'instances updated'.to_json
end

# SSHKey API

get '/api/sshkeys/:id' do
  @sshkey = Sshkey[params[:id]]
  if @sshkey.nil?
    { status: 'no sshkey' }.to_json
  else
    @sshkey.to_json
  end
end

get '/api/sshkeys' do
  Sshkey.to_json
end

post '/api/sshkeys' do
  info = CommonUtil.sshkeygenerate
  # Use services like S3 or cloudfront in the future??
  send_file "/tmp/#{info[:name]}.pem", filename: "#{info[:name]}.pem", disposition: :attachment
end

put '/api/sshkeys/:id' do

end

delete '/api/sshkeys/:id' do
  result = CommonUtil.sshkeyremove(params[:id])
  if result
    { status: 'sshkey removed' }.to_json
  else
    { status: 'no sshkey' }.to_json
  end
end

# Container API

post '/api/containers/:name' do
  dm = Ctnmgr.new(settings.lxcnodes.first, settings.user, settings.pass)
  data = dm.launch_vm(params[:name])
  Instance.create(
  {
    name: params[:name],
    host_ip: settings.lxcnodes.first,
    guest_ip: data[:ip],
    created: Time.now,
    updated: Time.now
  })
  { status: 'container created' }.to_json
end

get '/api/containers/:id/start' do
  dm = Ctnmgr.new(settings.lxcnodes.first, settings.user, settings.pass)
  @container = Instance[params[:id]]
  data = dm.start_vm(@container.name)
  { status: 'container started' }.to_json
end

get '/api/containers/:id/stop' do
  dm = Ctnmgr.new(settings.lxcnodes.first, settings.user, settings.pass)
  @container = Instance[params[:id]]
  puts @container.inspect
  dm.stop_vm(@container.name)
  { status: 'container stopped' }.to_json
end

delete '/api/containers/:id' do
  dm = Ctnmgr.new(settings.lxcnodes.first, settings.user, settings.pass)
  @container = Instance[params[:id]]
  dm.destroy_vm(@container.name)
  @container.delete
  { status: 'container deleted' }.to_json
end
