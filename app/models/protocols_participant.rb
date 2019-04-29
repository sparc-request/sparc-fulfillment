class ProtocolsParticipant < ApplicationRecord
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
