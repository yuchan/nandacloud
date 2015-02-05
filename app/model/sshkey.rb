require 'bundler'
Bundler.require

Sequel::Model.plugin :json_serializer
# Establish the database connection; or, omit this and use the DATABASE_URL
# environment variable as the connection string:
set :database, 'sqlite://instances.db'

puts "the sshkeys table doesn't exist" if !database.table_exists?('sshkeys')

migration "create sshkeys table" do
  database.create_table :sshkeys do
    primary_key :id
    string      :name
    string      :secret_key
    string      :public_key
    timestamp   :created, :null => false
    timestamp   :updated, :null => false
  end
end

class Sshkey < Sequel::Model
end
