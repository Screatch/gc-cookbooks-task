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
  'config/unicorn.rb' => 'config/unicorn.rb'
}

default['deploy_path'] = '/var/www'
default['deploy_user'] = 'deploy'
default['deploy_group'] = 'deploy'
default['deploy_home'] = '/home/deploy'
default['migrate'] = true