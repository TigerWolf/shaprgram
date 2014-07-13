# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

begin
  load File.expand_path("../bin/spring", __FILE__)
rescue LoadError
end
require File.expand_path('../config/application',  __FILE__)
require './config/boot'

Rails.application.load_tasks
