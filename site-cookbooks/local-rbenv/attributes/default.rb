override['rbenv']['group_users'] = node['local-rbenv']['group_users']

node.from_file(run_context.resolve_attribute('rbenv', 'default'))
