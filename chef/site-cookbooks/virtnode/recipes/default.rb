#
# Cookbook Name:: virtnode
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

%w{qemu-kvm libvirt virt-install virt-viewer bridge-utils}.each do |pkg|
    package pkg do
        action :install
    end
end

