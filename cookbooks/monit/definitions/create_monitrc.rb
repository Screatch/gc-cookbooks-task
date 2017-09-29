define :create_monitrc, :action => :enable, :variables => {}, :time => :delayed do
  tsource = params[:template].nil? ? "#{params[:name]}.monitrc.erb" : params[:template]

  if params[:action] == :enable
    template "/etc/monit/conf.d/#{params[:name]}.monitrc" do
      cookbook 'monit'
      owner 'root'
      group 'root'
      mode 0644
      source tsource
      variables params[:variables]
      notifies :restart, 'service[monit]', params[:time]
      action :create
    end
  else
    file "/etc/monit/conf.d/#{params[:name]}.monitrc" do
      action :delete
      notifies :restart, 'service[monit]'
    end
  end
end
