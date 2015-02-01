require 'bundler'
Bundler.require

Sequel::Model.plugin :json_serializer
# Establish the database connection; or, omit this and use the DATABASE_URL
# environment variable as the connection string:
set :database, 'sqlite://instances.db'

# At this point, you can access the Sequel Database object using the
# "database" object:
puts "the instances table doesn't exist" if !database.table_exists?('instances')

# define database migrations. pending migrations are run at startup and
# are guaranteed to run exactly once per database.
migration "create instances table" do
  database.create_table :instances do
    primary_key :id
    string      :name
    string      :instance_path 
    string      :host_ip, :null => false
    string      :guest_ip
    timestamp   :created, :null => false
    timestamp   :updated, :null => false
  end
end

# models just work ...
class Instance < Sequel::Model
end
