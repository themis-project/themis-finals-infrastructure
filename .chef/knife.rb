require 'dotenv'
::Dotenv.load

local_mode true
cookbook_path ['cookbooks']
node_path 'nodes'
role_path 'roles'
environment_path 'environments'
data_bag_path 'data_bags'

environment = ::ENV['CHEF_ENV'] || 'development'
knife[:environment] = environment

encrypted_data_bag_secret_file = ::ENV.fetch(
  "CHEF_ENCRYPTED_DATA_BAG_SECRET_FILE_#{environment.upcase}",
  nil
)

ignore_encrypted_data_bag_secret = \
  ::ENV.fetch("CHEF_IGNORE_ENCRYPTED_DATA_BAG_SECRET_#{environment.upcase}", 'no') == 'yes'

unless ignore_encrypted_data_bag_secret
  if !encrypted_data_bag_secret_file.nil? && ::File.exist?(encrypted_data_bag_secret_file)
    encrypted_data_bag_secret encrypted_data_bag_secret_file
  else
    raise 'Couldn\'t find any encrypted data bag secret for environment'\
          " <#{environment}>!"
  end
end

knife[:berkshelf_path] = 'cookbooks'
::Chef::Config[:ssl_verify_mode] = :verify_peer if defined? Chef
