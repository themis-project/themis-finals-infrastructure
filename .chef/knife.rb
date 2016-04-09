require 'dotenv'
Dotenv.load

cookbook_path ['cookbooks', 'site-cookbooks']
node_path 'nodes'
role_path 'roles'
environment_path 'environments'
data_bag_path 'data_bags'

environment = ENV['CHEF_ENV'] || 'development'
encrypted_data_bag_secret "encryption_keys/#{environment}_key"

knife[:berkshelf_path] = 'cookbooks'
