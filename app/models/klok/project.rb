class Klok::Project < ActiveRecord::Base
  include KlokShard

  self.primary_key = 'project_id'
  
  has_many :klok_entries, class_name: 'Klok::Entry', foreign_key: :project_id
  has_many :klok_people, class_name: 'Klok::Person', foreign_key: :resource_id, through: :klok_entries
  belongs_to :parent_project, class_name: 'Klok::Project', foreign_key: :parent_id
  has_many :child_projects, class_name: 'Klok::Project', foreign_key: :parent_id
  belongs_to :service, foreign_key: :code

  def ssr_id
    parent_project.try(:code) || code
  end

  def local_protocol
    sparc_id, ssr_version = ssr_id.split('-')
    Protocol.where(sparc_id: sparc_id).select{|p| p.sub_service_request.ssr_id == ssr_version}.first
  end
end
