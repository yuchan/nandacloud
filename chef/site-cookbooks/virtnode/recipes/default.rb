#
# Cookbook Name:: virtnode
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#

case node["platform"]
when "debian", "ubuntu"
%w{qemu-kvm libvirt-bin ubuntu-vm-builder virtinst virt-viewer bridge-utils}.each do |pkg|
 package pkg do
   action :install
 end
end
when "redhat", "centos", "fedora"
%w{qemu-kvm libvirt virt-install virt-viewer bridge-utils}.each do |pkg|
  package pkg do
    action :install
  end
end
end
