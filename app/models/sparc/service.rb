# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class Sparc::Service < ApplicationRecord

  include SparcShard

  belongs_to :organization
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

  def displayed_pricing_map date=Date.today
    unless self.verify_display_dates
      raise TypeError, "One of service's pricing maps has no display date!"
    end
    if pricing_maps && !pricing_maps.empty?
      current_date = (date || Date.today).to_date
      current_maps = pricing_maps.select {|x| x.display_date <= current_date}
      if current_maps.empty?
        raise ArgumentError, "Service has no current pricing maps!"
      else
        # If two pricing maps have the same display_date, prefer the most
        # recently created pricing_map.
        pricing_map = current_maps.sort {|a,b| [b.display_date, b.id] <=> [a.display_date, a.id]}.first
      end

      return pricing_map
    else
      raise ArgumentError, "Service has no pricing maps!"
    end
  end

  def verify_display_dates
    is_valid = true
    self.pricing_maps.each do |map|
      unless map.display_date
        is_valid = false
      end
    end

    is_valid
  end
end
