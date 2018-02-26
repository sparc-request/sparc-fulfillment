# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

class Service < ApplicationRecord

  include SparcShard

  belongs_to :organization

  has_many :line_items
  has_many :pricing_maps
  has_many :pricing_setups, through: :organization
  has_many :procedures
  has_many :fulfillments

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

  def current_effective_pricing_map(date = Time.current)
    pricing_maps.current(date).first
  end

  def current_effective_pricing_setup(date = Time.current)
    organization.effective_pricing_setup_for_date(date)
  end
end
