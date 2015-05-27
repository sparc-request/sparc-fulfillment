class Service < ActiveRecord::Base

  include SparcShard

  belongs_to :organization

  has_many :line_items
  has_many :service_level_components
  has_many :pricing_maps

  default_scope { order(name: :asc) }

  scope :per_participant,  -> { where(one_time_fee: false) }
  scope :one_time_fee, -> { where(one_time_fee: true) }

  # TODO Determine exact cost calculation
  def cost
    if pricing_map = current_effective_pricing_map
      return pricing_map.full_rate
    else
      raise ArgumentError, "Service #{self.id} has no pricing maps"
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
