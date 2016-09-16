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

  def decimal_duration
    minutes = duration/60000
    minutes/60.0
  end

  def klok_project_present
    unless self.klok_project.present?
      self.errors[:base] << 'Klok Project not present'
    end
  end

  def klok_project_ssr_id
    unless self.klok_project.ssr_id
      self.errors[:base] << 'Doesnt have SSR ID'
    end
  end

  def klok_project_ssr_id_regex_error
    unless self.klok_project.ssr_id.match(/\d\d\d\d-\d\d\d\d/)
      self.errors[:base] << 'no match'
    end
  end

  def local_project_error
    unless self.local_protocol.present?
      self.errors[:base] << 'no local project'
    end
  end

  def service_error
    unless self.service.present?
      self.errors[:base] << 'no service'
    end
  end

  def klok_person_error
    unless self.klok_person.present?
      self.errors[:base] << 'no klok person'
    end
  end

  def local_identity_error
    unless self.local_identity.present?
      self.errors[:base] << 'no local identity'
    end
  end

  def error_messages
    klok_project_present
    klok_project_ssr_id
    klok_project_ssr_id_regex_error
    local_project_error
    service_error
    klok_person_error
    local_identity_error
    return self.errors[:base]
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
