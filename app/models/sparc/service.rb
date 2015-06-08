class Sparc::Service < ActiveRecord::Base

  include SparcShard

  has_many :line_items
  has_many :pricing_maps

  def current_effective_pricing_map
    return effective_pricing_map_for_date(Date.today)
  end

  def effective_pricing_map_for_date(date=Date.today)
    raise ArgumentError, "Service has no pricing maps" if self.pricing_maps.empty?

    # TODO: use #where? (warning: potential performance issue)
    current_maps = self.pricing_maps.select { |x| x.effective_date.to_date <= date.to_date }
    raise ArgumentError, "Service has no current pricing maps" if current_maps.empty?

    sorted_maps = current_maps.sort { |lhs, rhs| lhs.effective_date <=> rhs.effective_date }
    pricing_map = sorted_maps.last

    return pricing_map
  end
end
