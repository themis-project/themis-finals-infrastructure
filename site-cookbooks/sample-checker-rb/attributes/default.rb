id = 'themis-finals-sample-checker-rb'

default[id][:basedir] = '/var/themis/finals/checkers/sample-checker-rb'
default[id][:repository] = 'aspyatkin/themis-finals-sample-checker-rb'
default[id][:revision] = 'master'
default[id][:user] = 'vagrant'
default[id][:group] = 'vagrant'

default[id][:log_level] = 'DEBUG'
default[id][:stdout_sync] = false
default[id][:service_alias] = 'service_1'
default[id][:processes] = 2
default[id][:ruby_version] = '2.3.0'
