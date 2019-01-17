#
# Cookbook:: apache2
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.
apt_update 'update' do
  action :periodic
end

apt_package 'apache2' do
#  version '2.4.18-2'
  action :install
end

cookbook_file '/var/www/html/index.html' do
  source 'index.html'
end

execute 'restarting apache' do
  command 'service apache2 restart'
  user 'root'
end
