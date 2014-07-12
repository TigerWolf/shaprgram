include_recipe 'rbenv::system'

['libyaml-devel', 'libyaml', 'openssl-devel'].each do |name|
  package name do
    action :upgrade
  end
end

rbenv_ruby "2.1.1" do
  action :install
end

rbenv_gem 'bundler' do
  rbenv_version '2.1.1'
end