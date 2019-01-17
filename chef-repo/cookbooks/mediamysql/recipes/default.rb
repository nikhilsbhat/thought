#
# Cookbook:: mediamysql
# Recipe:: default
#
# Copyright:: 2019, The Authors, All Rights Reserved.

mysql_service 'wiki' do
  port         '3306'
  bind_address '0.0.0.0'
  version      '5.6'
  initial_root_password 'Ch4ng3me'
  action       [:create, :start]
end
