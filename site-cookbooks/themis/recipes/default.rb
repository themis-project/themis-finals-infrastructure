directory '/var/themis' do
    owner 'vagrant'
    group 'vagrant'
    mode '0755'
    action :create
end

rbenv_ruby '2.2.2' do
    ruby_version '2.2.2'
    global true
end

rbenv_gem 'bundler' do
    ruby_version '2.2.2'
end

git '/var/themis/finals' do
    repository node[:themis][:repository]
    revision node[:themis][:revision]
    enable_checkout false
    user node[:themis][:user]
    group node[:themis][:group]
    action :sync
end