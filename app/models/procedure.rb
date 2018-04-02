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

class Procedure < ApplicationRecord

  STATUS_TYPES = %w(complete incomplete follow_up unstarted).freeze

  NOTABLE_REASONS  = ['Assessment missed', 'Gender-specific assessment',
                      'Specimen/Assessment could not be obtained', 'Individual assessment completed elsewhere',
                      'Assessment not yet IRB approved', 'Duplicated assessment',
                      'Assessment performed by other personnel/study staff', 'Participant refused assessment',
                      'Assessment not performed due to equipment failure', 'Not collected/not done--unknown reason',
                      'Not applicable for this visit'].freeze

  has_paper_trail
  acts_as_paranoid

  has_one :protocol,    through: :appointment
  has_one :arm,         through: :appointment
  has_one :participant, through: :appointment
  has_one :visit_group, through: :appointment
  has_one :task,        as: :assignable, dependent: :destroy

  belongs_to :appointment
  belongs_to :visit
  belongs_to :service
  belongs_to :performer, class_name: "Identity"
  belongs_to :core, class_name: "Organization", foreign_key: :sparc_core_id

  has_many :notes, as: :notable
  has_many :tasks, as: :assignable

  before_update :set_save_dependencies

  validates_inclusion_of :status, in: STATUS_TYPES,
                                  if: Proc.new { |procedure| procedure.status.present? }

  validate :cost_available, if: Proc.new { |procedure| procedure.status == "complete"}

  accepts_nested_attributes_for :notes

  scope :untouched,   -> { where(status: 'unstarted') }
  scope :incomplete,  -> { where(status: 'incomplete') }
  scope :complete,    -> { where(status: 'complete') }

  # select Procedures that belong to an Appointment without a start date
  scope :belonging_to_unbegun_appt, -> { joins(:appointment).where('appointments.start_date IS NULL') }
  scope :completed_r_in_date_range, ->(start_date, end_date) {
        where("procedures.completed_date is not NULL AND procedures.completed_date between ? AND ? AND billing_type = ?", start_date, end_date, "research_billing_qty")}

  def self.billing_display
    [["R", "research_billing_qty"],
     ["T", "insurance_billing_qty"],
     ["O", "other_billing_qty"]]
  end

  def performable_by
    #Returns identities that are allowed to be the performer for this procedure, formatted for an options_for_select helper
    Identity.joins(:clinical_providers).where(clinical_providers: {organization: self.protocol.organization}).map {|identity| [identity.full_name, identity.id]}
  end

  def formatted_billing_type
    case self.billing_type
    when "research_billing_qty"
      return "R"
    when "insurance_billing_qty"
      return "T"
    when "other_billing_qty"
      return "O"
    end
  end

  def group_id
    "#{formatted_billing_type}_#{service_id}"
  end

  # Has this procedure's appointment started?
  def appt_started?
    appointment.start_date.present?
  end

  def handled_date
    if complete?
      return completed_date
    elsif incomplete?
      return incompleted_date
    elsif follow_up?
      return task.created_at
    else
      return nil
    end
  end

  def follow_up_date
    if task.present?
      return task.due_at
    else
      return nil
    end
  end

  def complete?
    status == 'complete'
  end

  def incomplete?
    status == 'incomplete'
  end

  def follow_up?
    status == 'follow_up'
  end

  def unstarted?
    status == 'unstarted'
  end

  def reason_note
    if incomplete?
      notes.select{|note| note.reason?}.last
    end
  end

  def destroy
    if unstarted?
      super
    else
      raise ActiveRecord::ActiveRecordError
    end
  end

  def destroy_regardless_of_status
    #Destroy task, since delete won't fire after_destroy hooks
    task.destroy if task
    #Destroy notes, for same reason
    notes.destroy_all if notes.any?
    #Finally, delete, not destroy procedure
    self.delete
  end

  def reset
    #Remove tasks
    task.destroy if task

    #Remove notes
    notes.destroy_all if notes.any?

    # reload to reflect deleted associations
    self.reload

    #Reset Status
    self.update_attributes(status: "unstarted")
    self.update_attributes(service_cost: nil)
    self.reload
  end

  def completed_date=(completed_date)
    if completed_date.present?
      write_attribute(:completed_date, Time.strptime(completed_date, "%m/%d/%Y"))
    else
      write_attribute(:completed_date, nil)
    end
  end

  def service_name
    if unstarted?
      service.present? ? service.name : ''
    else
      read_attribute(:service_name)
    end
  end

  def cost(funding_source = protocol.sparc_funding_source, date = Time.current)
    if service_cost
      service_cost.to_i
    else
      new_cost(funding_source, date)
    end
  end

  private

  def cost_available
    date = completed_date ? completed_date : Date.today
    if visit
      cost = visit.line_item.try(:cost, protocol.sparc_funding_source, date) rescue nil
    else
      cost = service.try(:cost, protocol.sparc_funding_source, date) rescue nil
    end

    if cost.nil?
      errors[:service_cost] << "No cost found, ensure that a valid pricing map exists for that date."
    end
  end

  def new_cost(funding_source, date)
    if visit
      visit.line_item.cost(funding_source, date).to_i
    else
      service.cost(funding_source, date).to_i
    end
  end

  def set_save_dependencies
    if status_changed?(from: "unstarted") && service.present?
      write_attribute(:service_name, service.name)
    end

    if status_changed?(to: "complete") || complete?
      write_attribute(:incompleted_date, nil)
      if completed_date.nil?
        write_attribute(:completed_date, Date.today)
      end
    elsif status_changed?(to: "incomplete") || incomplete?
      write_attribute(:completed_date, nil)
      write_attribute(:incompleted_date, Date.today)
    elsif status_changed?(to: "unstarted") or status_changed?(to: "follow_up")
      write_attribute(:completed_date, nil)
      write_attribute(:incompleted_date, nil)
      if task.present?
        write_attribute(:status, "follow_up")
      end
    end

    if status_changed?(to: "complete")
      write_attribute(:service_cost, new_cost(protocol.sparc_funding_source, completed_date))
    end

    if status_changed?(from: "complete")
      write_attribute(:service_cost, nil)
    end

    if completed_date_changed? && !completed_date_changed?(to: nil)
      write_attribute(:service_cost, new_cost(protocol.sparc_funding_source, completed_date))
    end
  end
end
