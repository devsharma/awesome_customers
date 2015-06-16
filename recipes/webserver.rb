#
# Cookbook Name:: awesome_customers
# Recipe:: webserver
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
# Install the Apache package on the node
include_recipe 'apache2::default'

#create and enable our customers site
web_app node['awesome_customers']['name'] do
  template "#{node['awesome_customers']['config']}.erb"
end

#create the document root
directory node['apache']['docroot_dir'] do
  recursive true
end

#Create default home page for the web server
template "#{node['apache']['docroot_dir']}index.php" do
  source 'index.php.erb'
  mode '0644'
  owner node['awesome_customers']['user']
  group node['awesome_customers']['group']
end

firewall_rule 'http' do
  port 80
  protocol :tcp
  action :allow
end

#Include Php to the enabled apache module
include_recipe 'apache2::mod_php5'

package 'php5-mysql' do
	action :install
	notifies :restart, 'service[apache2]'
end
