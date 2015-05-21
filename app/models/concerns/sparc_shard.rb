require 'active_support/concern'

module SparcShard

  extend ActiveSupport::Concern

  included do

    octopus_establish_connection(Octopus.config[Rails.env][:sparc])

    allow_shard :sparc

    def readonly?
      Rails.env.production?
    end

    def self.sparc_record?
      true
    end

    # Allow queries (in particular, JOINs) across both SPARC and
    # CWF databases by explicitly prefixing the appropriate SPARC
    # database name to tables belonging to it.
    def self.table_name_prefix
      Octopus.config[Rails.env][:sparc][:database] + '.'
    end
  end
end
