require 'active_support/concern'

module KlokShard

  extend ActiveSupport::Concern

  included do

    octopus_establish_connection(Octopus.config[Rails.env][:klok])

    allow_shard :klok

    def self.inherited(child)
      child.octopus_establish_connection Octopus.config[Rails.env][:klok]
      super
    end

    def readonly?
      Rails.env.production?
    end

    def self.klok_record?
      true
    end

    # Allow queries (in particular, JOINs) across both Klok and
    # CWF databases by explicitly prefixing the appropriate Klok
    # database name to tables belonging to it.
    def self.table_name_prefix
      Octopus.config[Rails.env][:klok][:database] + '.'
    end
  end
end
