class Participant < ActiveRecord::Base

  ETHNICITY_OPTIONS = ['Hispanic or Latino', 'Not Hispanic or Latino'].freeze
  RACE_OPTIONS      = ['Caucasian', 'African American/Black', 'Asian', 'Middle Eastern', 'Pacific Islander', 'Native American/Alaskan', 'Other'].freeze
  STATUS_OPTIONS    = ['Active', 'Inactive', 'Complete'].freeze
  GENDER_OPTIONS    = ['Male', 'Female'].freeze

  acts_as_paranoid

  belongs_to :protocol
  belongs_to :arm
  has_many :appointments

  after_save :update_faye
  after_destroy :update_faye

  validates :protocol_id, :first_name, :last_name, :mrn, :date_of_birth, :phone, :ethnicity, :race, :gender, presence: true
  validate :phone_number_format, :date_of_birth_format

  def phone_number_format
    if phone != ""
      unless /^\d{3}-\d{3}-\d{4}$/.match phone.to_s
        errors.add(:phone, "is not a phone number in the format XXX-XXX-XXXX")
      end
    end
  end

  def date_of_birth_format
    unless /^\d{4}-\d{2}-\d{2}$/.match date_of_birth.to_s
      errors.add(:date_of_birth, "is not a date in the format YYYY-MM-DD")
    end
  end

  def build_appointments
    ActiveRecord::Base.transaction do
      if self.arm
        if self.appointments.empty?
          appointments_for_visit_groups(self.arm.visit_groups)
        elsif has_new_visit_groups?
          appointments_for_visit_groups(new_visit_groups)
        end
      end
    end
  end

  def update_appointments_on_arm_change
    self.appointments.each{ |appt| appt.destroy_if_incomplete }
    self.build_appointments
  end

  private

  def update_faye
    FayeJob.enqueue protocol.id
  end

  def has_new_visit_groups?
    self.arm.visit_groups.count > self.appointments.count
  end

  def new_visit_groups
    participant_vgs = self.appointments.map{|app| app.visit_group}
    arm_vgs = self.arm.visit_groups
    arm_vgs - participant_vgs
  end

  def appointments_for_visit_groups visit_groups
    visit_groups.each do |vg|
      self.appointments.create(visit_group_id: vg.id, visit_group_position: vg.position, position: self.appointments.count + 1, name: vg.name)
    end
  end
end
