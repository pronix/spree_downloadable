require 'spree_core'
require 'spree_downloadable_hooks'

module SpreeDownloadable
  class Engine < Rails::Engine

    require "#{config.root}/lib/download_app"
    config.autoload_paths += %W(#{config.root}/lib)
    initializer "download_app" do |app|
      app.middleware.use DownloadApp
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
