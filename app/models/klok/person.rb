class Klok::Person < ActiveRecord::Base
  include KlokShard

  self.primary_key = 'resource_id'
  
  has_many :klok_entries, class_name: 'Klok::Entry', foreign_key: :resource_id
  has_many :klok_projects, class_name: 'Klok::Project', foreign_key: :resource_id, through: :klok_entries

  def local_identity
    ldap_uid = name.split(" ").last.gsub(/[\(\)]*/, '')
    ldap_uid += "@musc.edu" #### TODO, update Klok so that @musc.edu is added
    Identity.where(ldap_uid: ldap_uid).first
  end 

end
