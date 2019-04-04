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

require 'factory_bot_rails'

namespace :data do

  desc 'Create fake data in CWF'
  task generate_data: :environment do

    # Destroy Old Fake Data
    clean_old_fake_data

    # Globally unique :sparc_ids
    FactoryBot.define { sequence(:sparc_id) }

    # Create Indentity
    identity = FactoryBot.create(:identity, email: 'email@musc.edu', ldap_uid: 'ldap@musc.edu', password: 'password')

    # Create 10 Protocols
    10.times do
      sub_service_request = FactoryBot.create(:sub_service_request_with_organization)
      protocol            = FactoryBot.create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
      parent_organization = FactoryBot.create(:organization, type: "Provider")
      organization        = sub_service_request.organization
      organization.update_attributes(parent: parent_organization)
      FactoryBot.create(:clinical_provider, identity: identity, organization: organization)
      FactoryBot.create(:project_role_pi, identity: identity, protocol: protocol)
    end

    # Create 10 tasks
    10.times do
      identity.tasks.push FactoryBot.create(:task, assignee: identity)
    end
  end
end

def clean_old_fake_data # from the sparc side
  fake_identities = Identity.where( email: "email@musc.edu")                        # find fake identities
  fake_identities.each{ |dent| dent.project_roles.destroy_all }                     # destroy fake project roles
  fake_identities.each{ |dent| dent.clinical_providers.destroy_all }                # destroy fake clinical providers
  fake_identities.destroy_all                                                       # destroy fake identities

  fake_organizations = Organization.where('name LIKE ?', '%Fake Organization %')    # find fake organizations
  fake_organizations.each{ |org| org.sub_service_requests.destroy_all }             # destroy fake sub_service_requests
  fake_organizations.destroy_all                                                    # destroy fake organizations
end
