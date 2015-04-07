class Participant < ActiveRecord::Base

  ETHNICITY_OPTIONS   = ['Hispanic or Latino', 'Not Hispanic or Latino'].freeze
  RACE_OPTIONS        = ['American Indian/Alaska Native', 'Asian', 'Native Hawaiian or other Pacific Islander', 'Black or African American', 'White', 'Unknown/Other/Unreported'].freeze
  STATUS_OPTIONS      = ['Consented','Screening', 'Enrolled – receiving treatment', 'Follow-up', 'Completed'].freeze
  GENDER_OPTIONS      = ['Male', 'Female'].freeze
  RECRUITMENT_OPTIONS = ['', 'Participating Site Referral', 'Primary Physician / or Healthcare Provider Referred', 'Other Physician / or Healthcare Provider Referred', 'Local Advertising (Flyer, Brochure, Newspaper, etc.)', 'Friends or Family Referred', 'SC Research.org', 'MUSC Heroes.org', 'Clinical Trials.gov', 'Billboard Ad Campaign', 'TV Ad Campaign', 'Other'].freeze

  has_paper_trail
  acts_as_paranoid

  belongs_to :protocol
  belongs_to :arm

  has_many :appointments

  after_save :update_faye
  after_destroy :update_faye

  validates :protocol_id, :first_name, :last_name, :mrn, :date_of_birth, :ethnicity, :race, :gender, presence: true
  validate :phone_number_format, :date_of_birth_format, :middle_initial_format, :zip_code_format

  def phone_number_format
    if !phone.blank?
      if not( /^\d{3}-\d{3}-\d{4}$/.match phone.to_s or /^\d{10}$/.match phone.to_s )
        errors.add(:phone, "is not a phone number in the format XXX-XXX-XXXX or XXXXXXXXXX")
      end
    end
  end

  def zip_code_format
    if !zipcode.blank?
      if not( /^\d{5}$/.match zipcode.to_s )
        errors.add(:zipcode, "is not a zip code in the format XXXXX")
      end
    end
  end

  def middle_initial_format
    if !middle_initial.blank?
      if not( /^[A-z]{1}$/.match middle_initial.to_s )
        errors.add(:middle_initial, "must be only one character")
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

  def full_name
    [first_name, middle_initial, last_name].join(' ')
  end

  private

  def update_faye
    FayeJob.enqueue protocol
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
