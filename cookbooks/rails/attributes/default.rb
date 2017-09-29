default['migrate'] = true
default['rails_env'] = 'production'
default['migrate_command'] = 'bundle exec rake db:migrate'
default['restart_command'] = 'monit -g deployment restart'
default['deploy_path'] = '/var/www'

default['sidekiq']['concurrency'] = [node[:cpu][:total].to_i * 4].min

default['shared_folders'] = [
  'bin','log','pids','sockets',
  'cache','vendor/bundle',
  'system','assets','uploads',
  'config'
]
default['folders_to_delete'] = [
  'bin','log','tmp/pids','tmp/sockets',
  'tmp/cache','vendor/bundle',
  'public/system','public/uploads'
]
default['symlinks'] = {
  'bin' => 'bin',
  'log' => 'log',
  'pids' => 'tmp/pids',
  'sockets' => 'tmp/sockets',
  'cache' => 'tmp/cache',
  'vendor/bundle' => 'vendor/bundle',
  'system' => 'public/system',
  'assets' => 'public/assets',
  'uploads' => 'public/uploads'
}
default['symlinks_before_migrate'] = {
  'config/database.yml' => 'config/database.yml',
  'config/secrets.yml' => 'config/secrets.yml',
  'config/settings.yml' => 'config/settings.yml',
  'config/unicorn.rb' => 'config/unicorn.rb',
  'config/mongoid.yml' => 'config/mongoid.yml'
}
