# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.paths << "#{Rails.root}/vendor/assets/" 
Rails.application.config.assets.precompile += %w(font-awesome.min.css.erb  ink.css.erb  ink-flex.css.erb  ink-ie.min.css.erb  ink-legacy.css.erb  quick-start.css.erb)

Dir[Rails.root.join("vendor", "*", "*")].each do |path|
  Rails.application.config.assets.paths << path
end

require 'sass/rails'
module Sprockets
  class SassImporter < Sass::Importers::Filesystem
    def extensions
      {
        'css'          => :scss,
        'css.scss'     => :scss,
        'css.sass'     => :sass,
        'css.erb'      => :scss,
        'scss.erb'     => :scss,
        'sass.erb'     => :sass,
        'css.scss.erb' => :scss,
        'css.sass.erb' => :sass
      }.merge!(super)
    end
  end
end