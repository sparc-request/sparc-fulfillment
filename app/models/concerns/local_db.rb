require 'active_support/concern'

LOCAL_CONFIG = Rails.configuration.database_configuration

module LocalDb

  extend ActiveSupport::Concern

  included do
    def self.table_name_prefix
      "#{LOCAL_CONFIG[Rails.env]["database"]}."
    end
  end
end
