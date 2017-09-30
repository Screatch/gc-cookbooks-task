include_recipe 'monit'

create_monitrc "unicorn_#{node['app_info']['name']}" do
	variables(
	  :appname => key,
	  :appinfo => app_info
	)
	template 'unicorn.monitrc.erb'
	time :immediately
end

