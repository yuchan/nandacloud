require 'bundler'
Bundler.require
require 'json'
require './model/instance'
require './lib/dcmgr'

get '/' do
  haml :index
end

get '/instances/:id' do
  @instances = Instance[params[:id]]
  @instances.to_s
end

delete '/instances/:id' do
  @instance = Instance[params[:id]]
  @instance.delete
end

get '/instances' do
  @instances = Instance.all
  @instances.to_s
end

post '/instances' do
  Dcmgr::ssh_connect
  "instance created"
end

post '/instances/:name' do
  dm = Dcmgr.new("192.168.33.21","vagrant","vagrant")
  dm.launch_vm(params[:name])
  "instance created".to_json
end

put "/instances/:id" do
  "instances updated"
end	

