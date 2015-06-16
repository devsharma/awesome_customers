#
# Cookbook Name:: awesome_customers
# Recipe:: database
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#Configure mysql2 gem
mysql2_chef_gem 'default' do
  action :install
end

#Configure the mysql client
mysql_client 'default' do
  action :create
end

#Load the secret file and load the data bags
#password_secret = Chef::EncryptedDataBagItem.load_secret("#{node['awesome_customers']['passwords']['secret_path']}")
#root_password_data_bag_item = Chef::EncryptedDataBagItem.load('password', 'sql_server_root_password', password_secret)

#Configure mysql service on the node
mysql_service 'default' do
  initial_root_password 'learnchef_mysql'
  action [:create, :start ]
end



mysql_database 'products' do
  connection(
    :host => node['awesome_customers']['database']['host'],
    :username => node['awesome_customers']['database']['username'],
    :password => 'learnchef_mysql'
  )
  action :create
end

#user_password_data_bag_item = Chef::EncryptedDataBagItem.load('password', 'db_admin', password_secret)

#Create db_admin user
mysql_database_user node['awesome_customers']['database']['app']['username'] do
  connection(
    :host => node['awesome_customers']['database']['host'],
    :username => node['awesome_customers']['database']['username'],
    :password => 'learnchef_mysql'
  )
  password 'database_password'
  database_name node['awesome_customers']['database']['dbname']
  host node['awesome_customers']['database']['host']
  action [ :create, :grant]
end

cookbook_file node['awesome_customers']['database']['seed_file'] do
  source 'create_tables.sql'
  owner 'root'
  group 'root'
  mode '0600'
end


execute 'initilize database' do
  command "mysql -h #{node['awesome_customers']['database']['host']} -u #{node['awesome_customers']['database']['app']['username']}-pdatabase_password -D products < #{node['awesome_customers']['database']['seed_file']}"
  not_if "mysql -h #{node['awesome_customers']['database']['host']} -u #{node['awesome_customers']['database']['app']['username']} -pdatabase_password -D products -e 'describe customers;'"
end
