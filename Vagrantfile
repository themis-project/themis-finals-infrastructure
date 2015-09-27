# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'json'


class MissingOptsFileError < Vagrant::Errors::VagrantError
  def initialize(filename)
    @filename = filename
    super
  end

  def error_message
    "Cannot find opts file `#{@filename}`!"
  end
end


class MissingVMBoxOptionError < Vagrant::Errors::VagrantError
  def error_message
    "Missing vm.box option in `opts.yaml` file!"
  end
end


class MissingVMNameOptionError < Vagrant::Errors::VagrantError
  def error_message
    "Missing vm.name option in `opts.yaml` file!"
  end
end


def get_node_opts
  filename = File.join __dir__, 'nodes', 'vagrant.json'
  if File.exists? filename
    JSON.load File.open filename
  else
    {}
  end
end


def get_vm_opts
  filename = File.join __dir__, 'opts.yaml'
  if File.exists? filename
    YAML.load File.open filename
  else
    raise MissingOptsFileError.new filename
  end
end


def set_vm_box(config, opts)
  vm_box = opts.fetch('vm', {}).fetch('box', nil)
  if vm_box.nil?
    raise MissingVMBoxOptionError.new
  end

  config.vm.box = vm_box
end


def set_vm_name(config, opts)
  vm_name = opts.fetch('vm', {}).fetch('name', nil)
  if vm_name.nil?
    raise MissingVMNameOptionError.new
  end

  config.vm.provider :virtualbox do |v|
      v.name = vm_name
  end
end


def set_vm_memory(config, opts)
  vm_memory = opts.fetch('vm', {}).fetch('memory', 512)

  config.vm.provider :virtualbox do |v|
    v.memory = vm_memory
  end
end


def set_vm_cpus(config, opts)
  vm_cpus = opts.fetch('vm', {}).fetch('cpus', 1)

  config.vm.provider :virtualbox do |v|
    v.cpus = vm_cpus
  end
end


def set_vm_hostname(config, opts)
  vm_hostname = opts.fetch('vm', {}).fetch('hostname', nil)

  unless vm_hostname.nil?
    config.vm.hostname = vm_hostname
  end
end


def set_vm_forwarded_ports(config, opts)
  vm_forwarded_ports = opts.fetch('vm', {}).fetch('network', {}).fetch('forwarded_ports', [])

  vm_forwarded_ports.each do |options|
    prepared_options = Hash[options.map { |(k, v)| [k.to_sym, v] }]
    config.vm.network :forwarded_port, **prepared_options
  end
end


def set_vm_public_networks(config, opts)
  vm_public_networks = opts.fetch('vm', {}).fetch('network', {}).fetch('public', [])

  vm_public_networks.each do |options|
    prepared_options = Hash[options.map { |(k, v)| [k.to_sym, v] }]
    config.vm.network :public_network, **prepared_options
  end
end


def set_vm_private_networks(config, opts)
  vm_private_networks = opts.fetch('vm', {}).fetch('network', {}).fetch('private', [])

  vm_private_networks.each do |options|
    prepared_options = Hash[options.map { |(k, v)| [k.to_sym, v] }]
    config.vm.network :private_network, **prepared_options
  end
end


def set_vm_synced_folders(config, opts)
  vm_synced_folders = opts.fetch('vm', {}).fetch('synced_folders', [])

  vm_synced_folders.each do |entry|
    prepared_options = Hash[entry.fetch('opts', {}).map { |(k,v)| [k.to_sym, v] }]
    config.vm.synced_folder entry['host'], entry['guest'], **prepared_options
  end
end


Vagrant.configure(2) do |config|
  vm_opts = get_vm_opts

  set_vm_box config, vm_opts
  set_vm_name config, vm_opts
  set_vm_memory config, vm_opts
  set_vm_cpus config, vm_opts
  set_vm_hostname config, vm_opts
  set_vm_forwarded_ports config, vm_opts
  set_vm_public_networks config, vm_opts
  set_vm_private_networks config, vm_opts
  set_vm_synced_folders config, vm_opts

  node_opts = get_node_opts

  config.librarian_chef.cheffile_dir = '.'
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ['site-cookbooks', 'cookbooks']
    chef.roles_path = 'roles'
    chef.data_bags_path = 'data_bags'
    chef.provisioning_path = '/tmp/vagrant-chef'

    chef.run_list = node_opts.delete 'run_list'
    chef.json = node_opts
  end
end
