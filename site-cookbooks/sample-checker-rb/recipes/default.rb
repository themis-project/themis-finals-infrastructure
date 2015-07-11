node_id = 'sample-checker-rb'

directory node[node_id][:basedir] do
    owner node[node_id][:user]
    group node[node_id][:group]
    mode '0755'
    recursive true
    action :create
end

git node[node_id][:basedir] do
    repository node[node_id][:repository]
    revision node[node_id][:revision]
    enable_checkout false
    user node[node_id][:user]
    group node[node_id][:group]
    action :sync
end

template "#{node[:themis][:basedir]}/god.d/sample-checker-rb.god" do
    source 'sample-checker-rb.god.erb'
    mode '0644'
end
