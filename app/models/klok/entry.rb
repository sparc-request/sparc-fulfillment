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
    minutes = duration/60000.0
    minutes/60.0
  end

  def local_protocol_includes_service service
    local_protocol.organization.inclusive_child_services(:one_time_fee, false).include? service
  end

  def is_valid?
    self.klok_project.present? &&
    self.klok_project.ssr_id &&
    ( /\d\d\d\d-\d\d\d\d/ === self.klok_project.ssr_id ) &&  #### validate we have a valid SSR id (comes from parent project)
    self.local_protocol.present? &&
    ( /\A\d+\z/ === self.klok_project.code ) &&  #### validate we actually have a service id and not a SSR id
    self.service.present? &&
    self.local_protocol_includes_service(self.service) &&
    self.klok_person.present? &&
    self.local_identity.present?
  end
end
