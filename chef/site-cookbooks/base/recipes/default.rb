#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w{gcc gcc-c++ make openssl-devel zlib-devel readline-devel libffi-devel}.each do |pkg|
   package pkg do
     action :install
   end
 end

