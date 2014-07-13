name 'server'
description 'Role to set up a base machine'
default_attributes(
   "xml" => { "packages" => ["libxml2-devel", "libxslt-devel"] },
   
  # "new_relic" => {
  #   "license_key" => ''
  # },
  "postfix" => {
    "mail_type" => "client",
    "main" => {
      # "mydomain" => "",
      # "myorigin" => "",
      # "relayhost" => "[smtp.gmail.com]:587",
      # "smtp_sasl_auth_enable" => "yes",
      # "smtp_use_tls" => "yes",
      # "smtp_tls_cafile" => "/etc/pki/tls/certs/ca-bundle.crt",
      # "smtp_sasl_security_options" => "noanonymous",
      # "smtp_sasl_passwd" => "",
      # "smtp_sasl_user_name" => '',
      # "myhostname" => %x{hostname}.strip || "localhost"
    },
  },
  "tz" => "Australia/Adelaide",
  "ruby_build" => {
    "upgrade" => "sync"
  }
)

run_list 'recipe[build-essential]', 'recipe[yum]', 'recipe[extra_yum_repos]', 'recipe[ruby_build]', 'recipe[git]', 'recipe[newrelic-sysmond::default]'#, 'recipe[postfix::default]', 'recipe[postfix::sasl_auth]'