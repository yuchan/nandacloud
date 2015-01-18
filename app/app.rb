require 'bundler'
Bundler.require
require 'json'
require './model/instance'
require './lib/dcmgr'

get '/' do
  haml :index
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

post '/testssh' do
  Dcmgr::ssh_connect
  "ssh connected".to_json
end

post '/instances/:name' do
  dm = Dcmgr.new("192.168.33.21","vagrant","vagrant")
  data = dm.launch_vm(params[:name])
  Instance.create({
    :name => params[:name],
    :host_ip => "192.168.33.21",
    :instance_path => data[:instance_path],
    :created => Time.now,
    :updated => Time.now
  })
  "instance created".to_json
end

delete '/instances/:id' do
  dm = Dcmgr.new("192.168.33.21","vagrant","vagrant")
  @instance = Instance[params[:id]]
  dm.remove_vm(@instance.name, @instance.instance_path)
  @instance.delete
  "instance removed".to_json
end

put "/instances/:id" do
  "instances updated".to_json
end	

