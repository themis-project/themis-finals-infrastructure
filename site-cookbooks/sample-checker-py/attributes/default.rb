id = 'themis-finals-sample-checker-py'

default[id][:basedir] = '/var/themis/finals/checkers/sample-checker-py'
default[id][:repository] = 'aspyatkin/themis-finals-sample-checker-py'
default[id][:revision] = 'master'
default[id][:user] = 'vagrant'
default[id][:group] = 'vagrant'

default[id][:log_level] = 'DEBUG'
default[id][:stdout_sync] = false
default[id][:service_alias] = 'service_2'
default[id][:processes] = 2
