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

class Sparc::LineItem < ActiveRecord::Base
  
  include SparcShard
  
  belongs_to :service
  belongs_to :service_request
  belongs_to :sub_service_request

  has_many :fulfillments
  has_many :line_items_visits
  has_many :arms, through: :line_items_visits
  has_many :admin_rates
  attr_accessor :pricing_scheme

  delegate  :name, to: :service

  scope :per_participant,  -> { includes(:service).where(:services => {one_time_fee: false}) }
  scope :one_time_fee,     -> { includes(:service).where(:services => {one_time_fee: true}) }

  def pricing_scheme
    @pricing_scheme || 'displayed'
  end

  def quantity_total(line_items_visit)
    # quantity_total = self.visits.map {|x| x.research_billing_qty}.inject(:+) * self.subject_count
    quantity_total = line_items_visit.visits.sum('research_billing_qty')
    return quantity_total * (line_items_visit.subject_count || 0)
  end

  def per_unit_cost(quantity_total=self.quantity, appointment_completed_date=nil)
    units_per_quantity = self.units_per_quantity
    if quantity_total == 0 || quantity_total.nil?
      0
    else
      total_quantity = units_per_quantity * quantity_total
      # Need to divide by the unit factor here. Defaulted to 1 if there isn't one
      packages_we_have_to_get = (total_quantity.to_f / self.units_per_package.to_f).ceil
      # The total cost is the number of packages times the rate
      total_cost = packages_we_have_to_get.to_f * self.applicable_rate(appointment_completed_date).to_f
      # And the cost per quantity is the total cost divided by the
      # quantity. The result here may not be a whole number if the
      # quantity is not a multiple of units per package.
      ret_cost = total_cost / quantity_total.to_f

      ret_cost
    end
  end

  def units_per_package
    unit_factor = self.service.displayed_pricing_map.unit_factor
    units_per_package = unit_factor || 1

    return units_per_package
  end

  def quantity_requested
    self.quantity
  end

  def direct_costs_for_one_time_fee
    # TODO: It's a little strange that per_unit_cost divides by
    # quantity, then here we multiply by quantity.  It would arguably be
    # better to calculate total cost here in its own method, then
    # implement per_unit_cost to call that method.
    num = self.quantity || 0.0
    num * self.per_unit_cost
  end

  def direct_costs_for_visit_based_service_single_subject(line_items_visit)
    # line items visit should also check that it's for the correct protocol
    return 0.0 unless service_request.protocol_id == line_items_visit.arm.protocol_id

    research_billing_qty_total = line_items_visit.visits.sum(:research_billing_qty)

    subject_total = research_billing_qty_total * per_unit_cost(quantity_total(line_items_visit))
    subject_total
  end

  # Determine the direct costs for a visit-based service
  def direct_costs_for_visit_based_service
    total = 0
    self.line_items_visits.each do |line_items_visit|
      total += (line_items_visit.subject_count || 0) * self.direct_costs_for_visit_based_service_single_subject(line_items_visit)
    end
    total
  end

  def applicable_rate(appointment_completed_date=nil)
    rate = nil
    if appointment_completed_date
      if has_admin_rates? appointment_completed_date
        rate = admin_rate_for_date(appointment_completed_date)
      else
        pricing_map         = self.pricing_scheme == 'displayed' ? self.service.displayed_pricing_map(appointment_completed_date) : self.service.effective_pricing_map_for_date(appointment_completed_date)
        pricing_setup       = self.pricing_scheme == 'displayed' ? self.service.organization.pricing_setup_for_date(appointment_completed_date) : self.service.organization.effective_pricing_setup_for_date(appointment_completed_date)
        funding_source      = self.service_request.protocol.funding_source_based_on_status
        selected_rate_type  = pricing_setup.rate_type(funding_source)
        applied_percentage  = pricing_setup.applied_percentage(selected_rate_type)

        rate = pricing_map.applicable_rate(selected_rate_type, applied_percentage)
      end
    else
      if has_admin_rates?
        rate = self.admin_rates.last.admin_cost
      else
        pricing_map         = self.pricing_scheme == 'displayed' ? self.service.displayed_pricing_map : self.service.current_effective_pricing_map
        pricing_setup       = self.pricing_scheme == 'displayed' ? self.service.organization.current_pricing_setup : self.service.organization.effective_pricing_setup_for_date
        funding_source      = self.service_request.protocol.funding_source_based_on_status
        selected_rate_type  = pricing_setup.rate_type(funding_source)
        applied_percentage  = pricing_setup.applied_percentage(selected_rate_type)

        rate = pricing_map.applicable_rate(selected_rate_type, applied_percentage)
      end
    end

    rate
  end

  def has_admin_rates? appointment_completed_date=nil
    has_admin_rates = !self.admin_rates.empty? && !self.admin_rates.last.admin_cost.blank?
    has_admin_rates = has_admin_rates && self.admin_rates.select{|ar| ar.created_at.to_date <= appointment_completed_date.to_date}.size > 0 if appointment_completed_date
    has_admin_rates
  end
end
