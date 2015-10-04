override['git']['version'] = '2.6.0'
override['git']['checksum'] = '807ebf4ea8a96a9a7e48be5101fb23e31135c1a084b041a25f9a5a76297d8140'

node.from_file(run_context.resolve_attribute('git', 'default'))
