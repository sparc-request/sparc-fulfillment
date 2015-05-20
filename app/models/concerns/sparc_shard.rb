require 'active_support/concern'

module SparcShard

  extend ActiveSupport::Concern

  included do

    octopus_establish_connection(
      adapter: "mysql2",
      database: ENV.fetch('SPARC_DB_PREFIX') + Rails.env.downcase)

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
      ENV.fetch('SPARC_DB_PREFIX') + Rails.env.downcase + "."
    end
  end
end
