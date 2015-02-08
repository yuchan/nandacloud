#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node["platform"]
when "debian", "ubuntu"
# do debian/ubuntu things
%w{libffi-dev autoconf}.each do |pkg|
  package pkg do
    action :install
  end
end
when "redhat", "centos", "fedora"
# do redhat/centos/fedora things
%w{libffi-devel autoconf}.each do |pkg|
  package pkg do
    action :install
  end
end
end


