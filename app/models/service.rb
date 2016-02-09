class Service < ActiveRecord::Base

  include SparcShard

  belongs_to :organization

  has_many :line_items
  has_many :pricing_maps
  has_many :pricing_setups, through: :organization
  has_many :procedures

  default_scope { order(name: :asc) }

  scope :per_participant,  -> { where(one_time_fee: false) }
  scope :one_time_fee, -> { where(one_time_fee: true) }

  def readonly?
    false
  end

  def cost(funding_source = nil, date = Time.current)
    pricing_map = current_effective_pricing_map(date)
    raise ArgumentError, "Service #{self.id} has no pricing maps" if pricing_map.blank?
    if funding_source.blank?

      return pricing_map.full_rate
    else
      pricing_setup = current_effective_pricing_setup(date)
      raise ArgumentError, "Service #{self.id} has no pricing setups" if pricing_setup.blank?
      rate_type = pricing_setup.rate_type(funding_source)
      rate_percentage = pricing_setup.rate_type_percentage(rate_type)

      return pricing_map.applicable_rate(rate_type, rate_percentage)
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

  def current_effective_pricing_setup date=Time.current
    organization.effective_pricing_setup_for_date(date)
  end
end
