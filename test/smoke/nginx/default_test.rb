describe file('/etc/nginx') do
  it { should be_directory }
end

describe file('/etc/nginx/nginx.conf') do
  it { should be_file }
end

describe nginx_conf.params['pid'] do
  it { should cmp [['/var/run/nginx.pid']] }
end