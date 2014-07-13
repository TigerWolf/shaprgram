override['nginx']['source']['modules'] = ['nginx::commons', 'nginx::ohai_plugin', 'nginx::http_ssl_module', 'nginx::passenger']
override['nginx']['default_site_enabled'] = false
override['nginx']['passenger']['version'] = "4.0.5"
override["nginx"]["passenger"]["root"] = "/opt/rbenv/versions/2.1.1/lib/ruby/gems/2.1.0/gems/passenger-#{node['nginx']['passenger']['version']}"
override["nginx"]["passenger"]["ruby"] = "/opt/rbenv/versions/2.1.1/bin/ruby"

override["nginx"]["passenger"]["max_pool_size"] = 15 #maximum memory allocation would be 1.4G for 100M per app
override["nginx"]["passenger"]["min_instances"] = 1 # start small
override["nginx"]["passenger"]["max_instances_per_app"] = 0
override["nginx"]["passenger"]["pool_idle_time"] = 300
override["nginx"]["passenger"]["max_requests"] = 0

default["deploy"]["environment"] = "production"
default["deploy"]["skip_seeds"] = false
default['sidekiq'] = {}





