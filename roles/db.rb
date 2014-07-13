name 'db'
description 'Role to set up a database server'

default_attributes({
  'postgresql' => {
    'server' => {
      'packages' => ['postgresql93-server', 'postgis2_93', 'postgresql93-contrib'] # Override cookbook default, 'cause its stupid
    },
    'password' => {
      'postgres' => 'md53175bce1d3201d16594cebf9d7eb3f9d', #postgres
    },
    'version' => "9.3",
    'config_pgtune' => {
      'tune_sysctl' => true
    }
  }
})

override_attributes({
  'postgresql' => {
    'config' => {
      'listen_addresses' => '0.0.0.0'
    },
    'pg_hba' => [
      {:type => 'local', :db => 'all', :user => 'all', :addr => nil, :method => 'trust'},
      {
        comment: '# IPv4 local connections:',
        addr: '127.0.0.1/32',
        type: 'host',
        db: 'all',
        user: 'all',
        method: 'trust'
      },
      {
        comment: '# IPv6 local connections:',
        addr: '::1/128',
        type: 'host',
        db: 'all',
        user: 'all',
        method: 'trust'
      }
    ]
  }
})

run_list  'role[server]', 'recipe[postgresql::yum_pgdg_postgresql]', 'recipe[postgresql::server]', 'recipe[postgresql::config_pgtune]', 'recipe[sysctl::default]'
