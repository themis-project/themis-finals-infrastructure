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
