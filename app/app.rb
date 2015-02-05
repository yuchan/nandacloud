require 'bundler'
Bundler.require
require 'json'
require './model/instance'
require './model/sshkey'
require './lib/dcmgr'
require './lib/ctnmgr'

config_file 'config.yml'

# GUI Console

get '/' do
  haml :index
end

get '/instances' do
  haml :instances
end

post '/instances' do
  @instance = Instance[:name => params[:name]]
  if @instance
    return "The name of instance was already used!"
  end
  @ip_list = Instance.select_map(:guest_ip)
  new_guest_ip = ""
  (10..200).each do |myhost|
    if @ip_list.include?("172.16.33.#{myhost}") == false then
      new_guest_ip = "172.16.33.#{myhost}"
    end
  end
  #return @ip_list
  if new_guest_ip == "" then
    return "Sorry, IP address is exhausted."
  end

  dm = Dcmgr.new('172.16.33.2', 'dcmgr', 'dcmgr')
  data = dm.launch_vm(params[:name], params[:keypair], new_guest_ip)
  Instance.create({
    name: params[:name],
    host_ip: '172.16.33.3',
    guest_ip: new_guest_ip,
    instance_path: "",
    created: Time.now,
    updated: Time.now
  })
  #{ status: 'instance created',ip: new_guest_ip }.to_json
  redirect to('/instances')
end

delete '/instances' do
  @instance = Instance[:name => params[:name]]
  if @instance
    dm = Dcmgr.new(@instance[:host_ip], 'dcnode', 'dcnode')
    dm.remove_vm(@instance.name)
    @instance.delete
  end
  redirect to('/instances')
end

get '/sshkeys' do
  haml :sshkeys
end

post '/sshkeys' do
  @sshkey = Sshkey[:name => params[:filename]]
  if @sshkey then
    return "ssh key pair file was already created!"
  end
  dm = Dcmgr.new('172.16.33.2', 'dcmgr', 'dcmgr')
  info = dm.generate_key(params[:filename])
  Sshkey.create({
    name: params[:filename],
    public_key: info[:result],
    created: Time.now,
    updated: Time.now
  })

  send_file "/home/dcmgr/nandacloud/keys/#{info[:name]}.pem", filename: "#{info[:name]}.pem", disposition: :attachment
end

# JSON api
post '/api/testssh' do
  Dcmgr::ssh_connect
  {:status => "ssh connected"}.to_json
end


get '/api/instances/:id' do
  @instance = Instance[params[:id]]
  if @instance == nil
    {:status => "no instance"}.to_json
  else
    @instance.to_json
  end
end

get '/api/instances' do
  Instance.to_json
end

post '/api/instances/:name' do
  dm = Dcmgr.new('192.168.33.21', 'vagrant', 'vagrant')
  data = dm.launch_vm(params[:name])
  Instance.create(
  {
    name: params[:name],
    host_ip: '192.168.33.21',
    instance_path: data[:instance_path],
    created: Time.now,
    updated: Time.now
  })
  { status: 'instance created' }.to_json
end

delete '/api/instances/:id' do
  dm = Dcmgr.new('192.168.33.21', 'vagrant', 'vagrant')
  @instance = Instance[params[:id]]
  if @instance
    dm.remove_vm(@instance.name, @instance.instance_path)
    @instance.delete
    { status: 'instance removed' }.to_json
  else
    { status: 'no instance' }.to_json
  end
end

put '/api/instances/:id' do
  'instances updated'.to_json
end

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
  dm = Dcmgr.new('192.168.33.25', 'vagrant', 'vagrant')
  info = dm.generate_key('test2')
  Sshkey.create(
  {
    name: info[:name],
    public_key: info[:result],
    created: Time.now,
    updated: Time.now
  })

  File.open("./out.txt", 'w') {|f| f.write(info[:result]) }
  send_file "./out.txt", filename: info[:name], disposition: :attachment
end

put '/api/sshkeys/:id' do

end

delete '/api/sshkeys/:id' do
  @sshkey = Sshkey[params[:id]]
  if @sshkey
    @sshkey.delete
    { status: 'sshkey removed' }.to_json
  else
    { status: 'no sshkey' }.to_json
  end
end

post '/api/containers/:name' do
  dm = Ctnmgr.new('192.168.33.25', 'vagrant', 'vagrant')
  data = dm.launch_vm(params[:name])
  Instance.create(
  {
    name: params[:name],
    host_ip: '192.168.33.25',
    guest_ip: data[:ip],
    created: Time.now,
    updated: Time.now
  })
  { status: 'container created' }.to_json
end
