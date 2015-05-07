require 'active_support/concern'

module SparcShard

  extend ActiveSupport::Concern

  included do

    octopus_establish_connection(
      adapter: "mysql2",
      database: "sparc-rails_#{Rails.env.downcase}")

    allow_shard :sparc

    def readonly?
      true
    end
  end
end
