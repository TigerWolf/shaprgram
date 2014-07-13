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

require 'rubygems'
require 'json'
Gem.clear_paths

include_recipe 'logrotate'

template "#{node['nginx']['dir']}/sites-available/shaprgram" do
  source "shaprgram.erb"
  owner "root"
  group "root"
  mode 00644
  notifies :reload, 'service[nginx]'
end

nginx_site 'shaprgram' do
  enable true
end


if node["newrelic"]
  execute "quiet-monitor" do
    command %Q{curl https://rpm.newrelic.com/accounts/#{node["newrelic"]["account_id"]}/applications/#{node["newrelic"]["shaprgram"]["application_id"]}/ping_targets/disable -X POST -H "X-Api-Key: #{node["newrelic"]["api_key"]}"}

    action :run
  end
end

artifact_deploy "shaprgram" do
  artifact_location "git://github.com/TigerWolf/shaprgram.git"
  deploy_to "/srv/shaprgram"
  owner "nginx"
  group "nginx"
  environment({ 'RAILS_ENV' => 'production', 'RBENV_ROOT' => '/opt/rbenv' })
  shared_directories %w{ data log pids system  assets }
  keep 1
  action :deploy
  notifies :reload, 'service[nginx]'
end

%w{ tmp tmp/pids tmp/sockets }.each do |dir|
  directory File.join("/srv/shaprgram/current", dir) do
    user 'nginx'
    group 'nginx'
    mode '0755'
    recursive true
    action :create
  end
end


if node["newrelic"]
  execute "enable-monitor" do
    command %Q{curl https://rpm.newrelic.com/accounts/#{node["newrelic"]["account_id"]}/applications/#{node["newrelic"]["shaprgram"]["application_id"]}/ping_targets/enable -X POST -H "X-Api-Key: #{node["newrelic"]["api_key"]}"}

    action :run
  end
end


# template '/srv/shaprgram/current/config/newrelic.yml' do
#   source "newrelic.yml.erb"

#   notifies :reload, 'service[nginx]'
# end


