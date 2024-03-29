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

class Appointment < ApplicationRecord
  VISIT_TYPES     = ['Lab Only', 'Space Only', 'PFT Only'].freeze
  STATUSES        = ['Skipped Visit', 'Visit happened elsewhere', 'Patient missed visit', 'No show', 'Visit happened outside of window'].freeze
  NOTABLE_REASONS = ['Assessment not performed', 'SAE/Follow-up for SAE', 'Patient Visit Conflict', 'Study Visit Assessments Inconclusive', 'Other'].freeze

  default_scope {order(:position)}

  has_paper_trail
  acts_as_paranoid
  acts_as_list scope: 'arm_id = #{arm_id} AND protocols_participant_id = #{protocols_participant_id} AND deleted_at IS NULL'

  include CustomPositioning #custom methods around positioning, acts_as_list

  belongs_to :arm, -> { with_deleted }
  belongs_to :protocols_participant
  belongs_to :visit_group

  has_one :protocol, through: :arm

  has_many :appointment_statuses, dependent: :destroy
  has_many :procedures, dependent: :destroy
  has_many :notes, as: :notable
  has_many :procedure_groups, dependent: :destroy

  scope :completed, -> { where('completed_date IS NOT NULL') }
  scope :incompleted, -> { where('appointments.completed_date IS NULL') }
  scope :unstarted, -> { where('appointments.start_date IS NULL AND appointments.completed_date IS NULL') }
  scope :with_completed_procedures, -> { joins(:procedures).where("procedures.completed_date IS NOT NULL") }

  validates :name, presence: true
  validates :arm_id, presence: true
  validates :protocols_participant_id, presence: true
  validate :completed_date_after_start_date

  accepts_nested_attributes_for :notes

  def find_or_create_procedure_group(sparc_core_id)
    self.procedure_groups.find_or_create_by(sparc_core_id: sparc_core_id)
  end

  def cores
    Organization.where(id: self.procedures.pluck(:sparc_core_id))
  end

  # Can appointment be finished? It must have a start date, and
  # all its procedures must either be complete, incomplete, or
  # have a follow up date assigned to it.

  def started?
    start_date.present?
  end

  def completed?
    self.completed_date.present?
  end

  def can_finish?
    !start_date.blank? && !procedures.untouched.any?
  end

  def has_completed_procedures?
    procedures.any?(&:completed_date)
  end

  def has_invoiced_procedures?
    procedures.any?(&:invoiced?)
  end

  def has_credited_procedures?
    procedures.any?(&:credited?)
  end

  def performable_by
    # List of clinical providers that can perform actions on an the appointment's procedures
    self.protocol.organization.clinical_provider_identities.order(:first_name, :last_name)
  end

  def procedures_grouped_by_core
    procedures.group_by(&:sparc_core_id)
  end

  def set_completed_date
    self.completed_date = Time.now
  end

  def destroy
    if can_be_destroyed?
      super
    else
      raise ActiveRecord::ActiveRecordError
    end
  end

  def can_be_destroyed?
    procedures.touched.empty?
  end

  def formatted_name
    self.type == 'CustomAppointment' ? "#{self.name} (Custom Visit)" : self.visit_group.identifier
  end

  private

  def completed_date_after_start_date
    if(start_date.present? && completed_date.present?)
      if(completed_date < start_date)
        errors.add(:completed_date, "must be the same, or later than start date.")
      end
    end
  end

end
