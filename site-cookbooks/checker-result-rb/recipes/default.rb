include_recipe 'latest-git'

node_id = 'checker-result-rb'

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
