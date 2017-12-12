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

class Appointment < ApplicationRecord

  STATUSES = ['Skipped Visit', 'Visit happened elsewhere', 'Patient missed visit', 'No show', 'Visit happened outside of window'].freeze
  NOTABLE_REASONS = ['Assessment not performed', 'SAE/Follow-up for SAE', 'Patient Visit Conflict', 'Study Visit Assessments Inconclusive'].freeze

  default_scope {order(:position)}

  has_paper_trail
  acts_as_paranoid
  acts_as_list scope: [:arm_id, :participant_id]

  include CustomPositioning #custom methods around positioning, acts_as_list

  has_one :protocol, through: :arm

  belongs_to :participant
  belongs_to :visit_group
  belongs_to :arm, -> { with_deleted }

  has_many :appointment_statuses, dependent: :destroy
  has_many :procedures
  has_many :notes, as: :notable

  scope :completed, -> { where('completed_date IS NOT NULL') }
  scope :incompleted, -> { where('appointments.completed_date IS NULL') }
  scope :unstarted, -> { where('appointments.start_date IS NULL AND appointments.completed_date IS NULL') }
  scope :with_completed_procedures, -> { joins(:procedures).where("procedures.completed_date IS NOT NULL") }

  validates :participant_id, presence: true
  validates :name, presence: true
  validates :arm_id, presence: true

  accepts_nested_attributes_for :notes

  # Can appointment be finished? It must have a start date, and
  # all its procedures must either be complete, incomplete, or
  # have a follow up date assigned to it.

  def started?
    start_date.present?
  end

  def can_finish?
    !start_date.blank? && (procedures.all? { |proc| !proc.unstarted? })
  end

  def has_completed_procedures?
    procedures.any?(&:completed_date)
  end

  def procedures_grouped_by_core
    procedures.group_by(&:sparc_core_id)
  end

  def set_completed_date
    self.completed_date = Time.now
  end

  def destroy_if_incomplete
    if not (completed_date || has_completed_procedures?)
      self.destroy
    end
  end

  def formatted_name
    self.type == 'CustomAppointment' ? "#{self.name} (Custom Visit)" : self.name
  end

  def initialize_procedures
    unless self.is_a? CustomAppointment # custom appointments don't inherit from the study schedule so there is nothing to build out
      ActiveRecord::Base.transaction do
        self.visit_group.arm.line_items.each do |li|
          visit = li.visits.where("visit_group_id = #{self.visit_group.id}").first
          if visit and visit.has_billing?
            attributes = {
              appointment_id: self.id,
              visit_id: visit.id,
              service_name: li.service.name,
              service_cost: li.cost(li.protocol.sparc_funding_source),
              service_id: li.service.id,
              sparc_core_id: li.service.sparc_core_id,
              sparc_core_name: li.service.sparc_core_name
            }
            visit.research_billing_qty.times do
              proc = Procedure.new(attributes)
              proc.billing_type = 'research_billing_qty'
              proc.save
            end
            visit.insurance_billing_qty.times do
              proc = Procedure.new(attributes)
              proc.billing_type = 'insurance_billing_qty'
              proc.save
            end
          end
        end
      end
    end
  end

end
