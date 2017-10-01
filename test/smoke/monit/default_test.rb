describe file('/etc/monit') do
  it { should be_directory }
end

describe file('/etc/monit/conf.d/nginx.monitrc') do
  it { should be_file }
end