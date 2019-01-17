#
# Cookbook:: wikimedia_base
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.
include_recipe 'apache2::default'
include_recipe 'php::default'

apt_package 'php-mysql' do
  action :install
end

apt_package 'libapache2-mod-php' do
  action :install
end

apt_package 'php-xml' do
  action :install
end

apt_package 'php-mbstring' do
  action :install
end

