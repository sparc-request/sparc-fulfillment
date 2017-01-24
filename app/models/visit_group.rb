# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

class VisitGroup < ActiveRecord::Base
  self.per_page = Visit.per_page

  has_paper_trail
  acts_as_paranoid
  acts_as_list scope: [:arm_id]

  belongs_to :arm

  has_many :visits, dependent: :destroy
  has_many :line_items, through: :arm
  has_many :appointments

  default_scope { order(:position) }

  validates :arm_id, presence: true
  validates :name, presence: true
  validates :window_before,
            :window_after,
            presence: true, numericality: { only_integer: true }
  validates :day, presence: true, unless: "ENV.fetch('USE_EPIC'){nil} == 'false'"
  validate :day_must_be_in_order, unless: "day.blank? || arm_id.blank?"
  validates :day, numericality: { only_integer: true }, unless: "day.blank?"

  before_destroy :check_for_completed_data

  def r_quantities_grouped_by_service
    visits.joins(:line_item).group(:service_id).sum(:research_billing_qty)
  end

  def t_quantities_grouped_by_service
    visits.joins(:line_item).group(:service_id).sum(:insurance_billing_qty)
  end

  private

  def check_for_completed_data
    self.appointments.each { |appt| appt.destroy_if_incomplete }
  end

  # Used to validate :day, when present. Preceding VisitGroup must have a
  # smaller :day, and succeeding VisitGroup must have a larger :day (on same Arm).
  def day_must_be_in_order
    already_there = arm.visit_groups.find_by(position: position) || arm.visit_groups.find_by(id: id)
    last_persisted_pos = arm.visit_groups.last.try(:position) || 0

    # determine neighbors that will be after save
    left_neighbor, right_neighbor =
      if id.nil? # inserting new record
        if position.nil? # insert as last
          [arm.visit_groups.last, nil]
        elsif position <= last_persisted_pos # inserting before
          [already_there.try(:higher_item), already_there]
        end
      else # moving present record
        if already_there.try(:id) == id # not changing position, get our neighbors
          [higher_item, lower_item]
        else # position must be changing
          if already_there.position < changed_attributes[:position]
            [already_there.try(:higher_item), already_there]
          else
            [already_there, already_there.try(:lower_item)]
          end
        end
      end

    if left_neighbor.try(:id) == id
      left_neighbor = nil
    end

    unless day > (left_neighbor.try(:day) || day - 1) && day < (right_neighbor.try(:day) || day + 1)
      errors.add(:day, 'must be in order')
    end
  end
end
