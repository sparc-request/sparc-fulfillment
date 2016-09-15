class Klok::Entry < ActiveRecord::Base
  include KlokShard
  validates :klok_project, presence: true
  validates :local_protocol, presence: true
  validates :service, presence: true
  validates :klok_person, presence: true
  validates :local_identity, presence: true


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

  def decimal_duration
    minutes = duration/60000
    minutes/60.0
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
