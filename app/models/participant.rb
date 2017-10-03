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

class Participant < ActiveRecord::Base

  ETHNICITY_OPTIONS   = ['Hispanic or Latino', 'Not Hispanic or Latino', 'Unknown/Other/Unreported'].freeze
  RACE_OPTIONS        = ['American Indian/Alaska Native', 'Asian', 'Middle Eastern', 'Native Hawaiian or other Pacific Islander', 'Black or African American', 'White', 'Unknown/Other/Unreported'].freeze
  STATUS_OPTIONS      = ['Consented','Screening', 'Enrolled - receiving treatment', 'Follow-up', 'Completed'].freeze
  GENDER_OPTIONS      = ['Male', 'Female'].freeze
  RECRUITMENT_OPTIONS = ['', 'Participating Site Referral', 'Primary Physician / or Healthcare Provider Referred', 'Other Physician / or Healthcare Provider Referred', 'Local Advertising (Flyer, Brochure, Newspaper, etc.)', 'Friends or Family Referred', 'SC Research.org', 'MUSC Heroes.org', 'Clinical Trials.gov', 'Billboard Ad Campaign', 'TV Ad Campaign', 'Other'].freeze

  has_paper_trail
  acts_as_paranoid

  belongs_to :protocol
  belongs_to :arm

  has_many :appointments
  has_many :procedures, through: :appointments
  has_many :notes, as: :notable

  delegate :srid,
           to: :protocol

  after_save :update_faye
  after_destroy :update_faye

  validates :protocol_id, presence: true
  validates :last_name, presence: true
  validates :first_name, presence: true

  validate :middle_initial_format

  validates :mrn, presence: true
  validates_length_of :mrn, maximum: 255

  validates :date_of_birth, presence: true
  validates :gender, presence: true
  validates :ethnicity, presence: true
  validates :race, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :state, presence: true

  validates :zipcode, presence: true
  validate :zip_code_format

  validate :phone_number_format

  def self.title id
    participant = Participant.find id
    [Protocol.title(participant.protocol.id), participant.last_name, participant.first_name].join(', ')
  end

  def date_of_birth=(dob)
    write_attribute(:date_of_birth, Time.strptime(dob, "%m/%d/%Y")) if dob.present?
  end

  def phone_number_format
    if !phone.blank?
      if not( /^\d{3}-\d{3}-\d{4}$/.match phone.to_s or /^\d{10}$/.match phone.to_s )
        errors.add(:phone, "must be in the format XXX-XXX-XXXX or XXXXXXXXXX")
      end
    end
  end

  def zip_code_format
    if !zipcode.blank?
      if not( /^\d{5}$/.match zipcode.to_s )
        errors.add(:zipcode, "must be in the format XXXXX")
      end
    end
  end

  def middle_initial_format
    if !middle_initial.blank?
      if not( /^[A-Za-z]$/.match middle_initial.to_s )
        errors.add(:middle_initial, "must be a single letter")
      end
    end
  end

  def label
    label = nil

    if not external_id.blank?
      label = "ID:#{external_id}"
    end

    if not mrn.blank?
      label = "MRN:#{mrn}"
    end

    label
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

  def full_name_with_label
    "(#{label}) #{full_name}"
  end

  def first_middle
    [first_name, middle_initial].join(' ')
  end

  def can_be_destroyed?
    procedures.where.not(status: 'unstarted').empty?
  end

  private

  def update_faye
    FayeJob.perform_later protocol
  end

  def has_new_visit_groups?
    self.arm.visit_groups.order(:id).pluck(:id) != self.appointments.where(arm_id: self.arm_id).where.not(visit_group_id: nil).order(:visit_group_id).pluck(:visit_group_id)
  end

  def new_visit_groups
    participant_vgs = self.appointments.map{|app| app.visit_group}
    arm_vgs = self.arm.visit_groups
    arm_vgs - participant_vgs
  end

  def appointments_for_visit_groups visit_groups
    visit_groups.each do |vg|
      self.appointments.create(visit_group_id: vg.id, visit_group_position: vg.position, position: nil, name: vg.name, arm_id: vg.arm_id)
    end
  end

end
