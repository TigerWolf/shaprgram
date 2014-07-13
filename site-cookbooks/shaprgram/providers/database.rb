action :create do
  config_file = ::File.join '/', 'srv', new_resource.app, 'current', 'config', "database.yml"
  node_config = "#{new_resource.app}_config"
  

  template config_file do
    source "database.yml.erb"
    owner "nginx"
    group "nginx"
    mode "0644"

    ['adapter', 'name', 'host', 'username'].each do |required|
      raise "Malformed configuration for: #{required}" unless node[node_config]['database'][required]
    end

    variables(
      environment: node['deploy']['environment'],
      adapter:     node[node_config]['database']['adapter'],
      database:    node[node_config]['database']['name'],
      host:        node[node_config]['database']['host'],
      username:    node[node_config]['database']['username'],
      password:    node[node_config]['database']['password']
    )
    action :create
  end if node[node_config] && node[node_config]['database']

  new_resource.updated_by_last_action(true)
end
