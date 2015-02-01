require 'bundler'
Bundler.require
require 'json'
require './model/instance'
require './model/sshkey'
require './lib/dcmgr'
require './lib/ctnmgr'

config_file 'config.yml'

get '/' do
  haml :index
end

post '/testssh' do
  Dcmgr::ssh_connect
  {:status => "ssh connected"}.to_json
end


get '/instances/:id' do
  @instance = Instance[params[:id]]
  if @instance == nil
    {:status => "no instance"}.to_json
  else
    @instance.to_json
  end
end

get '/instances' do
  Instance.to_json
end

post '/instances/:name' do
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


delete '/instances/:id' do
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

put '/instances/:id' do
  'instances updated'.to_json
end

get '/sshkeys/:id' do
  @sshkey = Sshkey[params[:id]]
  if @sshkey.nil?
    { status: 'no sshkey' }.to_json
  else
    @sshkey.to_json
  end
end

get '/sshkeys' do
  Sshkey.to_json
end

post '/sshkeys' do
  dm = Dcmgr.new('192.168.33.25', 'vagrant', 'vagrant')
  info = dm.generate_key('test2')
  Sshkey.create(
  {
    name: 'test2',
    public_key: info[:result],
    created: Time.now,
    updated: Time.now
  })
  
  puts info

  send_file "./#{info[:name]}", filename: info[:name], disposition: :attachment
end

put '/sshkeys/:id' do

end

delete '/sshkeys/:id' do
  @sshkey = Sshkey[params[:id]]
  if @sshkey
    @sshkey.delete
    { status: 'sshkey removed' }.to_json
  else
    { status: 'no sshkey' }.to_json
  end
end

post '/containers/:name' do
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

