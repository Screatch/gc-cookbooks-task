apt_update 'Updating list of packages' do
  action  :update
end

%w(
apt-transport-https
curl
git
htop
fail2ban
libssl-dev
openssl
vim
ntp
gcc
build-essential
nodejs
).each do |pkg|
  package pkg do
    action :install
  end
end

# cookbook_file "/root/.gemrc" do
#   source 'gemrc'
#   owner 'root'
#   group 'root'
#   mode '0644'
# end


# Periodic tasks
# Install security-updates automatically every day
file '/etc/apt/apt.conf.d/10periodic' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<-EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
  EOF
end

# Create deploy user and deploy group
group node['deploy_group'] do
  action :create
  name node['deploy_group']
  gid 1337
end

user node['deploy_user'] do
  action :create
  comment "deploy user"
  gid node['deploy_group']
  home node['deploy_home']
  manage_home true
  shell '/bin/bash'
  uid 31337
end

# Create user as sudo
group "create deploy_user as sudo" do
  group_name 'sudo'
  members node['deploy_user']
  action :modify
  append true
end

# Change sudoers file
template '/etc/sudoers' do
  source 'sudoers.erb'
  verify 'visudo -c -f %{path}'
end