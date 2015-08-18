include_recipe 'git'


package 'zsh'

node['oh-my-zsh']['entries'].each do |entry|
    home_dir = "/home/#{entry.user}"
    if entry.user == 'root'
        home_dir = '/root'
    end

    git "#{home_dir}/.oh-my-zsh" do
        repository 'https://github.com/robbyrussell/oh-my-zsh.git'
        revision 'master'
        enable_checkout false
        user entry.user
        group entry.group
        action :sync
    end

    git "#{home_dir}/.blank" do
        repository 'https://github.com/aspyatkin/blank'
        revision 'master'
        enable_checkout false
        user entry.user
        group entry.group
        action :sync
    end

    link "#{home_dir}/.oh-my-zsh/custom/blank.zsh-theme" do
        to "#{home_dir}/.blank/blank.zsh-theme"
    end

    template "#{home_dir}/.zshrc" do
        source 'zshrc.erb'
        owner entry.user
        group entry.group
    end

    execute 'set zsh as default shell' do
        command "chsh -s $(which zsh) #{entry.user}"
    end
end
