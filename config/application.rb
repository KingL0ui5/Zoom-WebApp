require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib)
  end
end
