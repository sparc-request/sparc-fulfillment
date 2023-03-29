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

class ProtocolsParticipant < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :protocol
  belongs_to :participant
  belongs_to :arm

  has_many :appointments, dependent: :destroy
  has_many :procedures, through: :appointments
  has_many :arms, -> { distinct }, through: :appointments

  attr_accessor :current_identity

  delegate :first_name, :last_name, :first_middle, :full_name, :mrn, to: :participant

  before_save :note_changes,                      if: Proc.new{ |p| p.arm_id_changed? || p.status_changed? }
  after_save :update_appointments_on_arm_change,  if: Proc.new{ |p| p.saved_change_to_arm_id? }

  scope :search, -> (term) {
    eager_load(:arm).where(participant: Participant.search(term)
    ).or(
      eager_load(:arm).where(ProtocolsParticipant.arel_table[:external_id].matches("%#{term}%"))
    ).or(
      eager_load(:arm).where(ProtocolsParticipant.arel_table[:status].matches("%#{term}%"))
    ).or(
      eager_load(:arm).where(ProtocolsParticipant.arel_table[:recruitment_source].matches("%#{term}%"))
    ).or(
      eager_load(:arm).where(Arm.arel_table[:name].matches("%#{term}%"))
    )
  }

  scope :sorted, -> (sort, order) {
    sort  = 'id' if sort.blank?
    order = 'desc' if order.blank?

    case sort
    when 'first_middle'
      joins(:participant).order(Participant.arel_table[:first_name].send(order), Participant.arel_table[:middle_initial].send(order))
    when 'last_name', 'mrn'
      joins(:participant).order(Participant.arel_table[sort].send(order))
    when 'arm'
      joins(:arm).order(Arm.arel_table[:name].send(order))
    else
      order(ProtocolsParticipant.arel_table[sort].send(order))
    end
  }

  def build_appointments
    ActiveRecord::Base.transaction do
      if arm
        if appointments.empty?
          create_appointments_for_visit_groups(arm.visit_groups)
        elsif has_new_visit_groups?
          create_appointments_for_visit_groups(new_visit_groups)
        end
      end
    end
  end

  def update_appointments_on_arm_change
    self.appointments.select(&:can_be_destroyed?).each(&:destroy)
    self.build_appointments
  end

  def label
    label = nil

    if not external_id.blank?
      label = "ID:#{external_id}"
    end

    label
  end

  private

  def has_new_visit_groups?
    new_visit_groups.any?
  end

  def new_visit_groups
    @new_visit_groups ||= self.arm.visit_groups.where.not(id: self.appointments.pluck(:visit_group_id))
  end

  def create_appointments_for_visit_groups visit_groups
    visit_groups.each do |vg|
      appointments.create(visit_group_id: vg.id, visit_group_position: vg.position, position: nil, name: vg.name, arm_id: vg.arm_id)
    end
  end

  def note_changes
    if status_changed?
      old_val = status_change[0].present? ? status_change[0] : I18n.t('actions.n_a')
      new_val = status_change[1].present? ? status_change[1] : I18n.t('actions.n_a')
      self.participant.notes.create(identity: self.current_identity, comment: I18n.t('participants.change_note', attr: self.class.human_attribute_name(:status), old: old_val, new: new_val))
    end
    if arm_id_changed?
      old_val = arm_id_change[0].present? ? Arm.find(arm_id_change[0]).name : I18n.t('actions.n_a')
      new_val = arm_id_change[1].present? ? Arm.find(arm_id_change[1]).name : I18n.t('actions.n_a')
      self.participant.notes.create(identity: self.current_identity, comment: I18n.t('participants.change_note', attr: self.class.human_attribute_name(:arm), old: old_val, new: new_val))
    end
  end
end
