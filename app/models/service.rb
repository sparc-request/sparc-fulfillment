class Service < ActiveRecord::Base

  include SparcShard

  belongs_to :organization

  has_many :line_items
  has_many :service_level_components
  has_many :pricing_maps

  default_scope { order(name: :asc) }

  # TODO: Limit is temporary. Eventually these will be filtered by organization
  scope :per_participant_visits,    -> { where(one_time_fee: 0).limit(50) }
  scope :one_time_fees,             -> { where(one_time_fee: 1).limit(50) }

  def self.all_cached
    Rails.cache.fetch("services_all", expires_in: 1.hour) do
      Service.all
    end
  end

  # TODO Determine exact cost calculation
  def cost
    if pricing_map = current_effective_pricing_map
      return pricing_map.full_rate
    else
      raise ArgumentError, "Service #{self.id} has no pricing maps"
    end
  end

  def self.all_per_participant_visit_services
    Rails.cache.fetch("cache_all_services", expires_in: 1.hour) do
      Service.where(one_time_fee: 0)
    end
  end

  def sparc_core_id
    organization.id
  end

  def sparc_core_name
    organization.name
  end

  def current_effective_pricing_map date=Time.current
    pricing_maps.current(date).first
  end
end
