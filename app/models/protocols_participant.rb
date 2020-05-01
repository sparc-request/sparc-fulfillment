# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

  after_save :update_faye
  after_destroy :update_faye

  validates :protocol_id, presence: true
  validates :participant_id, presence: true

  def build_appointments
    ActiveRecord::Base.transaction do
      if arm
        if appointments.empty?
          appointments_for_visit_groups(arm.visit_groups)
        elsif has_new_visit_groups?
          appointments_for_visit_groups(new_visit_groups)
        end
      end
    end
  end

  def update_appointments_on_arm_change
    appointments.each{ |appt| appt.destroy if appt.can_be_destroyed? }
    build_appointments
  end

  def can_be_destroyed?
    procedures.where.not(status: 'unstarted').empty?
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
    arm.visit_groups.order(:id).pluck(:id) != appointments.where(arm_id: arm_id).where.not(visit_group_id: nil).order(:visit_group_id).pluck(:visit_group_id)
  end

  def new_visit_groups
    participant_vgs = appointments.map{|app| app.visit_group}
    arm_vgs = arm.visit_groups
    arm_vgs - participant_vgs
  end

  def appointments_for_visit_groups visit_groups
    visit_groups.each do |vg|
      appointments.create(visit_group_id: vg.id, visit_group_position: vg.position, position: nil, name: vg.name, arm_id: vg.arm_id)
    end
  end

  def update_faye
    FayeJob.perform_later protocol
  end
end
