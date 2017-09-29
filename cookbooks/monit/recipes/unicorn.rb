include_recipe 'monit'

node['apps'].each do |key, app_info|
  create_monitrc "unicorn_#{key}" do
    variables(
      :appname => key,
      :appinfo => app_info
    )
    template 'unicorn.monitrc.erb'
    time :immediately
  end
end

