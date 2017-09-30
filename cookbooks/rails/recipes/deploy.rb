package 'postgresql-client'
package 'libpq-dev'

deploy_dir do
  path "#{node['deploy_path']}/#{node['app_settings']['name']}"
  folders node['shared_folders']
  user node['deploy_user']
  group node['deploy_group']
end

deploy "#{node['deploy_path']}/#{node['app_settings']['name']}" do
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

    bash "run bundle install in app directory" do
      cwd File.join(current_release)
      code "sudo bundle install --deployment"
    end

    template "#{node['deploy_path']}/#{node['app_settings']['name']}/shared/config/database.yml" do
      source "database.yml.erb"
      mode "0660"
      owner node['deploy_user']
      group node['deploy_group']
      variables(
        :database => node['app_settings']['database']
      )
    end

    # Create secrets yml
    template "#{node['deploy_path']}/#{node['app_settings']['name']}/shared/config/secrets.yml" do
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

    template "#{node['deploy_path']}/#{node['app_settings']['name']}/shared/config/unicorn.rb" do
      mode '0644'
      owner node['deploy_user']
      group node['deploy_group']
      source "unicorn.conf.erb"

      variables(
        :app => node['app_settings']['name'],
        :unicorn_settings => node['unicorn']
      )
    end
  end  

  before_restart do
    current_release = release_path

    bash "chmod bundle config" do
      cwd File.join(current_release)
      code "sudo chmod 666 .bundle/config"
    end

    bash "run asset precompile" do
      cwd File.join(current_release)
      code "bundle exec rake assets:precompile"
    end

  end

  # Restart using monit, requires root
  restart do
    execute "Restarting #{node['app_settings']['name']}" do
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
  path "/etc/nginx/sites-enabled/#{node['app_settings']['name']}.conf"
  source 'app.conf.erb'
  cookbook 'nginx'
  owner node['deploy_user']
  group node['deploy_group']
  mode 0644
  variables(
    :appname => node['app_settings']['name'],
    :deploy_to => "#{node['deploy_path']}/#{node['app_settings']['name']}",
    :domains => node['app_settings']['domains'],
    :ssl => true
  )
  only_if { File.exists?('/usr/sbin/nginx') }
  notifies :reload, 'service[nginx]'
end

