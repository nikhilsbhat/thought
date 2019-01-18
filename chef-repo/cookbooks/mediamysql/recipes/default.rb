#
# Cookbook:: mediamysql
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.
apt_update 'update' do
  action :periodic
end

mysql_service 'wiki' do
  port         '3306'
  bind_address '0.0.0.0'
  version      '5.7'
  initial_root_password 'Ch4ng3me'
#  provider     Chef::Provider::MysqlService::Sysvinit
  action       [:create, :start]
end
