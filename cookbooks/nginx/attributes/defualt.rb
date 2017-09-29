# Nginx config
os = node['platform']

default['nginx']['version'] = 'stable'
default['nginx']['mainline_url'] = "http://nginx.org/packages/mainline/#{os}/"
default['nginx']['stable_url'] = "http://nginx.org/packages/#{os}/"

default['nginx']['user'] = node['deploy_user']

default['nginx']['worker_processes'] = node['cpu']['total']
default['nginx']['worker_connections'] = 2048
default['nginx']['keepalive_timeout'] = 65
default['nginx']['client_max_body_size'] = '20M'
default['nginx']['gzip_types'] = [
  "text/plain",
  "text/css",
  "application/x-javascript",
  "application/json",
  "text/xml",
  "application/xml",
  "application/xml+rss",
  "text/javascript",
  "image/png",
  "image/gif",
  "image/jpeg"
]

default['nginx']['server_name'] = 'app.dev'
