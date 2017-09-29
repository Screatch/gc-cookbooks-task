# Set nginx_url depending on version selected in attributes.
case node['nginx']['version']
  when 'mainline'
    nginx_url = node['nginx']['mainline_url']
  when 'stable'
    nginx_url = node['nginx']['stable_url']
end

# Copy nginx_signing.key from nginx url
remote_file '/opt/nginx_signing.key' do
  source 'http://nginx.org/keys/nginx_signing.key'
end

# Add nginx signing key to apt and create customer resource list
execute 'add nginx key file to apt' do
  command 'apt-key add /opt/nginx_signing.key'
end

file '/etc/apt/sources.list.d/nginx.list' do
  content <<-EOF
deb #{nginx_url} #{node['lsb']['codename']} nginx
deb-src #{nginx_url} #{node['lsb']['codename']} nginx
  EOF
end

execute 'apt update' do
  command 'apt-get update'
end

apt_update 'Updating list of packages' do
  action  :update
end

package 'nginx'

service 'nginx' do
  action :nothing
end

# Remove default nginx conf
file '/etc/nginx/conf.d/default.conf' do
  action :delete
end

# Change default conf file
template 'nginx.conf' do
  path '/etc/nginx/nginx.conf'
  source 'nginx.conf.erb'
  notifies :enable, 'service[nginx]', :immediately
  notifies :start, 'service[nginx]', :immediately
end

# Change nginx logs permissions
execute "chown nginx logs" do
  command "chown -R #{node['deploy_user']}:#{node['deploy_group']} /var/log/nginx/"
  user 'root'
  action :run
end

# Create sites-enabled
directory '/etc/nginx/sites-enabled' do
  action :create
end

directory '/etc/nginx/ssl' do
  action :create
end

node['apps'].each do |key, app_info|
  data_bag = data_bag_item(key, 'nginx')

  file "/etc/nginx/ssl/#{key}.crt" do
    content data_bag['ssl']['crt']
  end

  file "/etc/nginx/ssl/#{key}.key" do
    content data_bag['ssl']['key']
  end
end

# dhparam
execute "openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048 > /dev/null 2>&1" do
  only_if { !::File.exist?('/etc/nginx/ssl/dhparam.pem') }
end


include_recipe('monit::nginx') if node.recipe?('monit')
