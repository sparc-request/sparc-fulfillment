require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ClinicalWorkFulfillment
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.time_zone = ENV.fetch('APPLICATION_TIME_ZONE')

    config.paths.add File.join('app', 'jobs'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'jobs', '*')]
    config.paths.add File.join('lib'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('lib')]
    config.paths.add File.join('lib/reports'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('lib/reports')]

    # Importers
    config.autoload_paths += Dir[Rails.root.join('lib/importers')]

    # DependentObjectImporter
    config.autoload_paths += Dir[Rails.root.join('lib/dependent_object_importers')]

    # Response compression
    config.middleware.use Rack::Deflater

    # Set RSpec as test framework
    config.generators do |generate|
      generate.test_framework :rspec
    end

    config.active_record.raise_in_transactional_callbacks = true

    # ActiveJob
    config.active_job.queue_adapter = :delayed_job

    # Force SSL
    config.force_ssl if ENV.fetch('GLOBAL_SCHEME') == 'https'
  end
end
