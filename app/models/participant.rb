# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

class Participant < ApplicationRecord

  ETHNICITY_OPTIONS   = ['Hispanic or Latino', 'Not Hispanic or Latino', 'Unknown/Other/Unreported'].freeze
  RACE_OPTIONS        = ['American Indian/Alaska Native', 'Asian', 'Middle Eastern', 'Native Hawaiian or other Pacific Islander', 'Black or African American', 'White', 'Unknown/Other/Unreported'].freeze
  STATUS_OPTIONS      = ['Consented','Screening', 'Enrolled - receiving treatment', 'Follow-up', 'Completed'].freeze
  GENDER_OPTIONS      = ['Male', 'Female'].freeze
  RECRUITMENT_OPTIONS = ['', 'Participating Site Referral', 'Primary Physician / or Healthcare Provider Referred', 'Other Physician / or Healthcare Provider Referred', 'Local Advertising (Flyer, Brochure, Newspaper, etc.)', 'Friends or Family Referred', 'SC Research.org', 'MUSC Heroes.org', 'Clinical Trials.gov', 'Billboard Ad Campaign', 'TV Ad Campaign', 'Other'].freeze

  has_paper_trail
  acts_as_paranoid

  has_many :notes, as: :notable
  has_many :protocols_participants, dependent: :destroy

  has_many :protocols, through: :protocols_participants
  has_many :appointments, through: :protocols_participants
  has_many :procedures, through: :appointments

  validates :last_name, presence: true
  validates :first_name, presence: true

  validate :middle_initial_format

  validates :mrn, presence: true
  validates_uniqueness_of :mrn
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

  scope :by_protocol_id, -> (protocol_id) {
    joins(:protocols_participants).where("protocols_participants.protocol_id = ? ", protocol_id)
  }

  scope :except_by_protocol_id, -> (protocol_id) {
    joins(:protocols_participants).where("protocols_participants.protocol_id != ? ", protocol_id)
  }

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

  def full_name
    [first_name, middle_initial, last_name].join(' ')
  end

  def full_name_with_label
    "(#{label}) #{full_name}"
  end

  def first_middle
    [first_name, middle_initial].join(' ')
  end

  def protocol_ids
    protocols.ids
  end

  def can_be_destroyed?
    procedures.where.not(status: 'unstarted').empty?
  end

  def destroy
    if can_be_destroyed?
      super
    else
      raise ActiveRecord::ActiveRecordError
    end
  end
end
