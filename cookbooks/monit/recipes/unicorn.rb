include_recipe 'monit'

create_monitrc "unicorn_#{node['app_settings']['name']}" do
	variables(
	  :appname => node['app_settings']['name']
	)
	template 'unicorn.monitrc.erb'
	time :immediately
end

