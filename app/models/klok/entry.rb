class Klok::Entry < ActiveRecord::Base
  include KlokShard

  self.primary_key = 'entry_id'

  belongs_to :klok_person, class_name: 'Klok::Person', foreign_key: :resource_id
  belongs_to :klok_project, class_name: 'Klok::Project', foreign_key: :project_id
  has_one :service, through: :klok_project

  delegate :local_protocol, 
           to: :klok_project,
           allow_nil: true

  delegate :local_identity,
           to: :klok_person,
           allow_nil: true

  def start_time_stamp=(value)
    super(DateTime.strptime(value,'%Q'))
  end

  def end_time_stamp=(value)
    super(DateTime.strptime(value,'%Q'))
  end

  def rounded_duration
    minutes = duration/60000.0
    (minutes/15.0).ceil * 15.0
  end

  def decimal_duration
    rounded_duration/60.0
  end

  def is_valid?
    self.klok_project.present? &&
    self.klok_project.ssr_id &&
    self.klok_project.ssr_id.match(/\d\d\d\d-\d\d\d\d/) &&
    self.local_protocol.present? &&
    self.service.present? &&
    self.klok_person.present? &&
    self.local_identity.present?
  end
end
