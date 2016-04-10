id = 'themis-finals-sample-checker-py'

include_recipe 'python::default'
include_recipe 'python::pip'
include_recipe 'python::virtualenv'

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

python_virtualenv "#{node[id][:basedir]}/.virtualenv" do
  owner node[id][:user]
  group node[id][:group]
  action :create
end

python_pip "#{node[id][:basedir]}/requirements.txt" do
  user node[id][:user]
  group node[id][:group]
  virtualenv "#{node[id][:basedir]}/.virtualenv"
  action :install
  options '-r'
end

template "#{node['themis-finals'][:basedir]}/god.d/sample-checker-py.god" do
  source 'checker.god.erb'
  mode 0644
end
