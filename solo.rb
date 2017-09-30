root = File.absolute_path(File.dirname(__FILE__))

file_cache_path root

cookbook_path root + '/cookbooks'
role_path root + '/cookbooks/roles'
json_attribs root+ "/cookbooks/roles/web.json"