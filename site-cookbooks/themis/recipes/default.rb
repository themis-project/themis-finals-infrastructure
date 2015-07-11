directory node[:themis][:basedir] do
    owner 'vagrant'
    group 'vagrant'
    mode '0755'
    recursive true
    action :create
end

rbenv_ruby '2.2.2' do
    ruby_version '2.2.2'
    global true
end

rbenv_gem 'bundler' do
    ruby_version '2.2.2'
end

rbenv_gem 'god' do
    ruby_version '2.2.2'
end

git node[:themis][:basedir] do
    repository node[:themis][:repository]
    revision node[:themis][:revision]
    enable_checkout false
    user node[:themis][:user]
    group node[:themis][:group]
    action :sync
end

postgresql_connection_info = {
    :host => '127.0.0.1',
    :port => node['postgresql']['config']['port'],
    :username => 'postgres',
    :password => node['postgresql']['password']['postgres']
}

postgresql_database 'themis' do
  connection postgresql_connection_info
  action :create
end

postgresql_database_user 'postgres' do
    connection postgresql_connection_info
    database_name 'themis'
    privileges [:all]
    action :grant
end

template "#{node[:themis][:basedir]}/god.d/queue.god" do
    source 'queue.god.erb'
    mode '0644'
end

template "#{node[:themis][:basedir]}/god.d/scheduler.god" do
    source 'scheduler.god.erb'
    mode '0644'
end

template "#{node[:themis][:basedir]}/god.d/backend.god" do
    source 'backend.god.erb'
    mode '0644'
end
