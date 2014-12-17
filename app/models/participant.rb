class Participant < ActiveRecord::Base
  acts_as_paranoid

  after_save :update_via_faye

  belongs_to :protocol
  belongs_to :arm

  validates :protocol_id, :first_name, :last_name, :mrn, :date_of_birth, :address, :phone, :status, :ethnicity, :race, :gender, presence: true
  validate :phone_number_format, :date_of_birth_format

  def phone_number_format
    unless /^\d{3}-\d{3}-\d{4}$/.match self.phone
      errors.add(:phone, "is not a phone number in the format XXX-XXX-XXXX")
    end
  end

  def date_of_birth_format
    unless /^\d{4}-\d{2}-\d{2}$/.match self.date_of_birth.to_s
      errors.add(:date_of_birth, "is not a date in the format YYYY-MM-DD")
    end
  end

  def update_via_faye
    channel = "/participants/#{self.protocol.id}/list"
    message = {:channel => channel, :data => "woohoo", :ext => {:auth_token => ENV['FAYE_TOKEN']}}
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end

  def self.ethnicity_options
    ['Hispanic or Latino', 'Not Hispanic or Latino']
  end

  def self.race_options
    ['Caucasian', 'African American', 'Hispanic', 'Asian / Pacific Islander', 'Other']
  end

  def self.status_options
    ['Active', 'Inactive', 'Complete']
  end

  def self.gender_options
    ['Male', 'Female']
  end
end
