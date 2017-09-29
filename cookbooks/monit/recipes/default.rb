tar_file = "monit-#{node['monit']['binary']['version']}.tar.gz"
cache_path = Chef::Config[:file_cache_path]
binary = "#{node['monit']['binary']['prefix']}/bin/monit"

# removing monitrc if it already exists
execute "rm #{binary}" do
  only_if { ::File.exist?(binary) }
  not_if "monit -V | grep #{node['monit']['binary']['version']}"
  notifies :create, "remote_file[#{cache_path}/#{tar_file}]", :immediately
end

# downloading monitrc
remote_file "#{cache_path}/#{tar_file}" do
  source node['monit']['binary']['url']
  action :create_if_missing
  notifies :run, 'execute[install-monit-binary]', :immediately
end

# installing monitrc
execute 'install-monit-binary' do
  cwd cache_path
  command [
              "tar zxvf #{tar_file}",
              "cd #{File.basename(tar_file, '.tar.gz')}",
              "if [ ! -f #{node['monit']['binary']['prefix']}/bin/monit ]; then cp bin/monit #{node['monit']['binary']['prefix']}/bin/monit ; fi"
          ].join(' && ')
  action :nothing
end

# configuration file
directory '/etc/monit/conf.d' do
  recursive true
  action :create
end

template node['monit']['main_config_path'] do
  owner  'root'
  group  'root'
  mode   '0600'
  source 'monitrc.erb'
end

template "/lib/systemd/system/monit.service" do
  owner 'root'
  group 'root'
  source 'monit.service.erb'
end

execute 'create-monitrc-link' do
  command "ln -sf #{node['monit']['main_config_path']} /etc/monitrc"
end

# build default monitrc files
node['monit']['default_monitrc_configs'].each do |conf|
  create_monitrc conf do
    time :immediately
  end
end

directory '/var/monit' do
  owner 'root'
  group 'root'
  mode  '0700'
end

# enable service startup
file '/etc/default/monit' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<-EOF
START=yes
MONIT_OPTS=#{node['monit']['init_opts']}
  EOF
  notifies :restart, 'service[monit]'
end

service 'monit' do
  supports [:start, :restart, :stop, :reload]
  action [:enable, :start]
  provider Chef::Provider::Service::Systemd
end
