# Be sure to restart your server when you modify this file.

# Include models, precompile
Rails.application.eager_load!
Rails.application.config.included_models = ActiveRecord::Base.descendants.map!(&:name)
# Solves Rails 4: 'Circular dependency detected while autoloading constant' RSPEC error
