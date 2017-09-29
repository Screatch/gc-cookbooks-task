deploy_dir do
  path "#{node['deploy_path']}/#{key}"
  folders node['shared_folders']
  user node['deploy_user']
  group node['deploy_group']
end

deploy "#{node['deploy_path']}/#{key}" do
  repo app_info['git']['repo']
  user node['deploy_user']
  group node['deploy_group']
  branch app_info['git']['branch']
  # environment app['environment'].to_hash
  environment "RAILS_ENV" => node['rails_env']
  migrate app_info['migrate'] || node['migrate']
  migration_command node['migrate_command']
  purge_before_symlink node['folders_to_delete']
  symlinks node['symlinks']
  symlink_before_migrate node['symlinks_before_migrate']
  # Before migration run bundle, assets:precompile and manifest backup.
  before_migrate do

    current_release = release_path

    Rails::Setup.bundle(
      current_release, node['deploy_user'],
      "#{node['deploy_path']}/#{key}"
    )

      template "#{current_release}/config/database.yml" do
        source "database.yml.erb"
        mode "0660"
        owner node['deploy_user']
        group node['deploy_group']
        variables(
          :database => node['database']
        )
    end

    # Create secrets yml
    template "#{node['deploy_path']}/#{key}/shared/config/secrets.yml" do
      cookbook "rails"
      source "secrets.yml.erb"
      mode "0660"
      owner node['deploy_user']
      group node['deploy_group']
      variables(
        :secrets => app_info['secrets'],
        :environment => node['rails_env']
      )
      only_if do
        app_info['secrets']
      end
    end

    if node.recipe?('rails::unicorn')

      # Unicorn config
      app_unicorn_settings = app_info['unicorn'] || {}
      unicorn_settings = node['unicorn'].merge(app_unicorn_settings)

      template "#{node['deploy_path']}/#{key}/shared/config/unicorn.rb" do
        cookbook 'unicorn'
        mode '0644'
        owner node['deploy_user']
        group node['deploy_group']
        source "unicorn.conf.erb"

        variables(
          :app => key,
          :unicorn_settings => unicorn_settings
        )
      end
    end

  end

  before_restart do
    current_release = release_path

    Rails::Setup.assets_precompile(
      current_release, node['deploy_user'], node['rails_env']
    )
    Rails::Setup.manifest_backup(current_release, node['deploy_user'])
  end

  # Restart using monit, requires root
  restart do
    execute "Restarting #{key}" do
      user 'root'
      command node['restart_command']
    end
  end

  action :deploy
end

unicorn_app do
  appname key
  appinfo app_info
  deploy_to "#{node['deploy_path']}/#{key}"
  domains app_info['domains']
end