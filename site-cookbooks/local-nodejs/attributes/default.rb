override['nodejs']['version'] = '4.0.0'
override['nodejs']['binary']['checksum']['linux_x64'] = 'df8ada31840e3dc48c7fe7291c7eba70b2ce5a6b6d959ac01157b04731c8a88f'

node.from_file(run_context.resolve_attribute('nodejs', 'default'))
