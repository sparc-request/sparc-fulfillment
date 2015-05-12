class Service < ActiveRecord::Base

  include SparcShard

  belongs_to :organization

  has_many :line_items
  has_many :service_level_components
  has_many :pricing_maps

  default_scope { order(name: :asc) }

  def self.all_cached
    Rails.cache.fetch("services_all", expires_in: 1.hour) do
      Service.all
    end
  end

  # TODO Determine exact cost calculation
  def cost
    if pricing_map = pricing_maps.current(Time.current).first
      return pricing_map.full_rate
    else
      raise ArgumentError, "Service has no pricing maps"
    end
  end

  def sparc_core_id
    organization.id
  end

  def sparc_core_name
    organization.name
  end
end
