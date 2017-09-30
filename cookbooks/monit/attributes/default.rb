default['monit']['nginx']['pid'] = '/var/run/nginx.pid'
default['monit']['nginx']['group'] = 'deploy'

default['monit']['sidekiq_workers'] = [node[:cpu][:total].to_i].min

default['monit']['init_opts'] = ''
default['monit']['default_monitrc_configs'] = %w[load ssh]

# Delay the start of polling when the service is started
default['monit']['start_delay'] = 0

# How frequently the monit daemon polls for changes.
default['monit']['polling_frequency'] = 10

# Only alert on specific events
default['monit']['alert_onlyif_events'] = []

# Ignore alerts for specific events
default['monit']['alert_ignore_events'] = []

# Where Monit stores unique Monit instance id
default['monit']['idfile'] = '/var/.monit.id'

# Where Monit stores Monit state file
default['monit']['statefile'] = '/var/lib/monit/state'

# Where Monit stores the pid file
default['monit']['pidfile'] = '/var/run/monit.pid'

# Use syslog for logging instead of a logfile.
default['monit']['use_syslog'] = false

# If not using syslog, the log file that monit will use.
default['monit']['logfile'] = '/var/log/monit.log'

# Enable the web interface and define credentials.
default['monit']['web_interface'] = {
    enable:  true,
    port:    2812,
    address: 'localhost',
    allow:   ['localhost', 'admin:b1gbr0th3r']
}

default['monit']['main_config_path'] = '/etc/monit/monitrc'
default['monit']['includes_dir'] = '/etc/monit/conf.d'

default['monit']['binary']['version'] = '5.20.0'
default['monit']['binary']['prefix'] = '/usr'
default['monit']['binary']['url'] = "http://mmonit.com/monit/dist/binary/#{node['monit']['binary']['version']}/monit-#{node['monit']['binary']['version']}-linux-x64.tar.gz"
