rbenv_gem 'passenger' do
  rbenv_version '2.1.1'
  version node['nginx']['passenger']['version']
end

include_recipe 'nginx::source'

directory "/var/www" do
  owner "nginx"
  group "nginx"
  mode 0755
  action :create
end

logrotate_app "access" do
  cookbook "logrotate"
  path "/var/log/nginx/access.log"
  frequency "daily"
  rotate 7
  size 1024*1024*100
  create "644 root adm"
  mail "daniel.oconnor@gmail.com"
end


logrotate_app "error" do
  cookbook "logrotate"
  path "/var/log/nginx/error.log"
  frequency "daily"
  rotate 7
  size 1024*1024*100
  create "644 root adm"
  mail "daniel.oconnor@gmail.com"
end

['mutt', 'mlocate', 'htop'].each do |name| 
  package name do
    action :upgrade
  end
end