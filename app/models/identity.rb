# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

class Identity < SparcDbBase
  devise :database_authenticatable, :rememberable, :trackable, :omniauthable

  belongs_to :professional_organization
  has_one :identity_counter, dependent: :destroy

  has_many :documents, as: :documentable
  has_many :project_roles
  has_many :notes, dependent: :destroy
  has_many :tasks, as: :assignable
  has_many :reports
  has_many :clinical_providers
  has_many :super_users
  has_many :patient_registrars

  delegate :tasks_count, :unaccessed_documents_count, to: :identity_counter

  def self.arel_full_name
    Identity.arel_table[:first_name].concat(Arel::Nodes.build_quoted(' ')).concat(Identity.arel_table[:last_name])
  end

  def protocols
    IdentityOrganizations.new(id).authorized_protocols
  end

  def protocols_organizations_ids
    IdentityOrganizations.new(id).fulfillment_organizations_with_protocols(false).pluck(:id).uniq
  end

  def billing_manager_protocols
    @billing_manager_protocols ||= IdentityOrganizations.new(id).authorized_billing_manager_protocols
  end

  def billing_manager_protocols_allow_credit
    @billing_manager_protocols_allow_credit ||= IdentityOrganizations.new(id).authorized_billing_manager_protocols_allow_credit
  end

  def protocols_full
    ##Includes relationship objects
    IdentityOrganizations.new(id).fulfillment_access_protocols
  end

  def readonly?
    false
  end

  def identity_counter
    IdentityCounter.find_or_create_by(identity: self)
  end

  # counter should be a symbol like :tasks for tasks_counter
  def update_counter(counter, amount)
    IdentityCounter.update_counter(self.id, counter, amount)
  end

  def full_name
    [first_name, last_name].join(' ')
  end

  def professional_org_lookup(org_type)
    professional_organization ? professional_organization.parents_and_self.select{|org| org.org_type == org_type}.first.try(:name) : ""
  end

  def is_a_patient_registrar?
    patient_registrars.any?
  end

  # DEVISE specific methods
  def self.find_for_shibboleth_oauth(auth, signed_in_resource=nil)
    identity = Identity.where(ldap_uid: auth.uid).first

    ##CWF doesn't need to create new ldap users
    # unless identity
    #   email = auth.info.email.blank? ? auth.uid : auth.info.email # in case shibboleth doesn't return the required parameters
    #   identity = Identity.create ldap_uid: auth.uid, first_name: auth.info.first_name, last_name: auth.info.last_name, email: email, password: Devise.friendly_token[0,20], approved: true
    # end
    
    identity
  end

end
