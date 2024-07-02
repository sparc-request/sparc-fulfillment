# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

class LineItem < ApplicationRecord

  has_paper_trail
  acts_as_paranoid

  belongs_to :protocol
  belongs_to :arm
  belongs_to :service
  belongs_to :sparc_line_item, class_name: 'Sparc::LineItem', foreign_key: :sparc_id
  has_many :fulfillments
  has_many :notes, as: :notable
  has_many :documents, as: :documentable
  has_many :components, as: :composable
  has_many :admin_rates, primary_key: :sparc_id
  has_many :admin_rate_changes, primary_key: :sparc_id


  has_many :visit_groups, through: :arm
  ##Commented out, because this isn't a direct connection, and is unintuitive.
  # has_many :appointments, through: :visit_groups

  has_many :visits, -> { includes(:visit_group).order("visit_groups.position") }, dependent: :destroy


  delegate  :name,
            :sparc_core_id,
            :sparc_core_name,
            :one_time_fee,
            to: :service,
            allow_nil: true

  validates :protocol_id, :service_id, presence: true
  validates :quantity_requested, presence: true, numericality: { greater_than_or_equal_to: 0 }, if: Proc.new { |li| li.one_time_fee }

  after_create :increment_sparc_service_counter
  after_destroy :decrement_sparc_service_counter

  def friendly_notable_type
    Service.model_name.human
  end

  def set_name
    update_attributes(name: service.name)
  end

  def name
    if one_time_fee && has_fulfillments?
      read_attribute(:name)
    else
      service.name
    end
  end

  def cost(funding_source = protocol.sparc_funding_source, date = Time.current)
    return current_admin_rate.admin_cost if current_admin_rate_applicable?(date)
    return applicable_old_admin_rate(date) if applicable_old_admin_rate(date)
    service.cost(funding_source, date).to_i
  end

  def name=(n)
    write_attribute(:name, n)
  end

  def increment_sparc_service_counter
    service.increment(:line_items_count)
  end

  def decrement_sparc_service_counter
    service.decrement(:line_items_count)
  end

  def started_at=(date)
    write_attribute(:started_at, Time.strptime(date, "%m/%d/%Y")) if date.present?
  end

  def quantity_fulfilled
    fulfillments.sum(&:quantity)
  end

  def quantity_remaining
    if one_time_fee and !fulfillments.empty?
      quantity_requested - quantity_fulfilled
    else
      quantity_requested
    end
  end

  def has_fulfillments?
    !fulfillments.empty?
  end

  def last_fulfillment
    if one_time_fee and !fulfillments.empty?
      fulfillments.order('fulfilled_at DESC').first.fulfilled_at
    end
  end

  private

  def current_admin_rate_applicable?(date)
    current_admin_rate && current_admin_rate.created_at.to_date <= date.to_date
  end

  def current_admin_rate
    protocol.sparc_protocol.service_requests
    .flat_map(&:sub_service_requests)
    .flat_map(&:line_items)
    .find { |line_item| line_item.service_id == service.id }
    &.admin_rates&.last
  end

  def old_admin_rates
    sparc_line_item = protocol.sparc_protocol.service_requests
    .flat_map(&:sub_service_requests)
    .flat_map(&:line_items)
    .find { |line_item| line_item.service_id == service.id }
    sparc_line_item&.admin_rate_changes || []
  end

  def applicable_old_admin_rate(date)
    old_rate = old_admin_rates.where("DATE(date_of_change) <= ?", date.to_date).order("date_of_change DESC").first
    old_rate&.admin_cost if !old_rate&.cost_reset
  end

end
