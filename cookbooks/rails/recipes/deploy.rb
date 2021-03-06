package 'postgresql-client'
package 'libpq-dev'

app_name = node['app_settings']['name']

# Create unicorn 
service "unicorn_#{app_name}" do
  supports :restart => true, :start => true, :stop => true, :reload => true
  action :nothing
end

template "unicorn_#{app_name}" do
  path "/etc/init.d/unicorn_#{app_name}"
  source 'unicorn.init.erb'
  owner 'root'
  group 'root'
  mode 0755
  variables(
    {
      :name => app_name,
      :path => "#{node['deploy_path']}/#{app_name}",
      :rails_env => node['rails_env'],
      :deploy_user => node['deploy_user']
    }
  )
end


deploy_dir do
  path "#{node['deploy_path']}/#{app_name}"
  folders node['shared_folders']
  user node['deploy_user']
  group node['deploy_group']
end

deploy "#{node['deploy_path']}/#{app_name}" do
  repo node['app_settings']['git']['repo']
  user node['deploy_user']
  group node['deploy_group']
  branch node['app_settings']['git']['branch']
  environment "RAILS_ENV" => node['rails_env']
  migrate node['migrate']
  migration_command node['migrate_command']
  purge_before_symlink node['folders_to_delete']
  symlinks node['symlinks']
  symlink_before_migrate node['symlinks_before_migrate']
  before_migrate do

    current_release = release_path

    execute "bundle install --deployment --path #{node['deploy_path']}/#{app_name}/shared/vendor" do
      user node['deploy_user']
      group node['deploy_group']
      cwd release_path
    end

    template "#{node['deploy_path']}/#{app_name}/shared/config/database.yml" do
      source "database.yml.erb"
      mode "0660"
      owner node['deploy_user']
      group node['deploy_group']
      variables(
        :database => node['app_settings']['database']
      )
    end

    # Create secrets yml
    template "#{node['deploy_path']}/#{app_name}/shared/config/secrets.yml" do
      cookbook "rails"
      source "secrets.yml.erb"
      mode "0660"
      owner node['deploy_user']
      group node['deploy_group']
      variables(
        :secrets => node['app_settings']['secrets'],
        :environment => node['rails_env']
      )
      only_if do
        node['app_settings']['secrets']
      end
    end

    template "#{node['deploy_path']}/#{app_name}/shared/config/unicorn.rb" do
      mode '0644'
      owner node['deploy_user']
      group node['deploy_group']
      source "unicorn.conf.erb"

      variables(
        :app => app_name,
        :unicorn_settings => node['unicorn']
      )
    end
  end  

  before_restart do
    current_release = release_path

    execute "RAILS_ENV=#{node['rails_env']} bundle exec rake assets:precompile && rm -rf #{release_path}/tmp/cache" do
      user node['deploy_user']
      group node['deploy_group']
      cwd File.join(current_release)
    end

    directory "#{release_path}/public/assets" do
      owner node['deploy_user']
      group node['deploy_group']
      mode '0755'
      recursive true
    end

  end

  # Restart using monit, requires root
  restart do
    execute "Restarting #{app_name}" do
      user 'root'
      command node['restart_command']
    end
  end

  action :deploy
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action :nothing
end

# Nginx conf files for each application
template 'nginx.conf' do
  path "/etc/nginx/sites-enabled/#{app_name}.conf"
  source 'app.conf.erb'
  cookbook 'nginx'
  owner node['deploy_user']
  group node['deploy_group']
  mode 0644
  variables(
    :appname => app_name,
    :deploy_to => "#{node['deploy_path']}/#{app_name}",
    :domains => node['app_settings']['domains'],
    :ssl => true
  )
  only_if { File.exists?('/usr/sbin/nginx') }
  notifies :reload, 'service[nginx]'
end

