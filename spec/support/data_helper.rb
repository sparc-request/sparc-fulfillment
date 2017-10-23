# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

module DataHelpers

  def create_and_assign_protocol_with_a_single_service
    identity              = Identity.first
    sub_service_request   = create(:sub_service_request_with_organization)
    protocol              = create(:protocol_with_single_service, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)
    create(:project_role_pi, identity: identity, protocol: protocol)

    protocol
  end

  def create_and_assign_protocol_with_duplicate_services
    identity              = Identity.first
    sub_service_request   = create(:sub_service_request_with_organization)
    protocol              = create(:protocol_with_duplicate_services, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)
    create(:project_role_pi, identity: identity, protocol: protocol)

    protocol
  end

  def create_and_assign_protocol_to_me
    identity              = Identity.first
    sub_service_request   = create(:sub_service_request_with_organization)
    subsidy               = create(:subsidy, sub_service_request: sub_service_request)
    protocol              = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)
    create(:project_role_pi, identity: identity, protocol: protocol)

    protocol
  end

  def create_and_assign_protocol_without_services_to_me
    identity              = Identity.first
    sub_service_request   = create(:sub_service_request_with_organization)
    protocol              = create(:protocol_imported_from_sparc, :without_services, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)
    create(:project_role_pi, identity: identity, protocol: protocol)

    protocol
  end

  def create_and_assign_blank_protocol_to_me
    identity              = Identity.first
    protocol              = create(:protocol_with_sub_service_request)
    organization          = protocol.organization
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)

    protocol
  end

  def create_and_assign_participant_to_me
    protocol = create_and_assign_protocol_to_me
    arm = create(:arm, protocol: protocol)
    create(:participant, arm: arm, protocol: protocol)
  end

  def create_and_assign_appointment_to_me
    participant = create_and_assign_participant_to_me
    create(:appointment, name: "Appointment", participant: participant, arm: participant.arm)
  end
end
