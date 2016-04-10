id = 'themis-finals-sample-checker-rb'

include_recipe 'latest-git::default'
include_recipe 'rbenv::default'
include_recipe 'rbenv::ruby_build'

directory node[id][:basedir] do
  owner node[id][:user]
  group node[id][:group]
  mode 0755
  recursive true
  action :create
end

url_repository = "https://github.com/#{node[id][:repository]}"

if node.chef_environment.start_with? 'development'
  ssh_key_map = data_bag_item('ssh', node.chef_environment).to_hash.fetch('keys', {})

  if ssh_key_map.size > 0
    url_repository = "git@github.com:#{node[id][:repository]}.git"
  end
end

git2 node[id][:basedir] do
  url url_repository
  branch node[id][:revision]
  user node[id][:user]
  group node[id][:group]
  action :create
end

if node.chef_environment.start_with? 'development'
  data_bag_item('git', node.chef_environment).to_hash.fetch('config', {}).each do |key, value|
    git_config "Git config #{key} at #{node[id][:basedir]}" do
      key key
      value value
      scope 'local'
      path node[id][:basedir]
      user node[id][:user]
      action :set
    end
  end
end

ENV['CONFIGURE_OPTS'] = '--disable-install-rdoc'

rbenv_ruby node[id][:ruby_version] do
  ruby_version node[id][:ruby_version]
  global true
end

rbenv_gem 'bundler' do
  ruby_version node[id][:ruby_version]
end

rbenv_execute "Install bundle at #{node[id][:basedir]}" do
  command 'bundle'
  ruby_version node[id][:ruby_version]
  cwd node[id][:basedir]
  user node[id][:user]
  group node[id][:group]
end

template "#{node['themis-finals'][:basedir]}/god.d/sample-checker-rb.god" do
  source 'checker.god.erb'
  mode 0644
end
