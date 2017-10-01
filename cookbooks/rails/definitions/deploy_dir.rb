define :deploy_dir do

  # Create main/shared folder
  directory "#{params[:path]}/shared" do
    group params[:group]
    owner params[:user]
    mode 0755
    action :create
    recursive true
  end

  # Create shared folders
  params[:folders].each do |dir_name|
    directory_path = "#{params[:path]}/shared/#{dir_name}"

    execute "[ -d #{directory_path} ] || mkdir -p -m 0770 #{directory_path}" do
      user params[:user]
      group params[:group]
      mode 0755
    end
  end

  # Change ownership of /var/www incase it's root-owned.
  Chef::Log.info "Helo, #{params}, #{params[:path]}"
  execute "changing_rights" do
    command "chmod 755 /var/www"
    user 'root'
    action :run
  end

end
