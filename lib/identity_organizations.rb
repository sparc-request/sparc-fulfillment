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

class IdentityOrganizations
  def initialize(id)
    @id = id
  end

  def fulfillment_access_protocols
    fetch_rights
    organization_ids = (@super_user_orgs.to_a + authorized_child_organizations(@super_user_orgs) + @clinical_provider_orgs.to_a).map(&:id).uniq

    Protocol.includes(
      :subsidy,
      :service_requests,
      human_subjects_info: [:irb_records],
      project_roles: [:identity],
      sparc_protocol: [:service_requests],
      sub_service_request: [:owner, :service_requester, :service_request]
    ).where(
      sub_service_requests: {organization_id: organization_ids}
    ).distinct
  end

  def authorized_protocols
    fetch_rights
    organization_ids = (@super_user_orgs.to_a + authorized_child_organizations(@super_user_orgs) + @clinical_provider_orgs.to_a).map(&:id).uniq
    
    Protocol.joins(:sub_service_request)
            .includes(sub_service_request: [:organization])
            .where(sub_service_requests: {organization_id: organization_ids})
            .distinct
  end

  def authorized_billing_manager_protocols
    billing_manager_orgs = Organization.includes(:super_users).where(super_users: {identity_id: @id, billing_manager: true}).references(:super_users).distinct
    org_ids = (billing_manager_orgs.to_a + authorized_child_organizations(billing_manager_orgs)).map(&:id).uniq
    
    Protocol.joins(:sub_service_request).where(sub_service_requests: {organization_id: org_ids}).distinct
  end

  def authorized_billing_manager_protocols_allow_credit
    billing_manager_orgs = Organization.includes(:super_users).where(super_users: {identity_id: @id, billing_manager: true, allow_credit: true}).references(:super_users).distinct
    org_ids = (billing_manager_orgs.to_a + authorized_child_organizations(billing_manager_orgs)).map(&:id).uniq
    
    Protocol.joins(:sub_service_request).where(sub_service_requests: {organization_id: org_ids}).distinct
  end

  def fulfillment_organizations_with_protocols(include_distinct=true)
    fetch_rights
    
    # 1. Combine all authorized organization objects and extract IDs securely
    authorized_orgs = @super_user_orgs.to_a + authorized_child_organizations(@super_user_orgs) + @clinical_provider_orgs.to_a
    org_ids = authorized_orgs.map(&:id).uniq

    # 2. Query directly against Protocol -> SubServiceRequest to bypass any Rails 7.2 `has_many :through` / STI quirks with Organization.joins(:protocols)
    org_ids_with_protocols = Protocol.joins(:sub_service_request)
                                     .where(sub_service_requests: { organization_id: org_ids })
                                     .pluck(:"sub_service_requests.organization_id")

    # 3. Fetch the final matched organizations
    organizations = Organization.where(id: org_ids_with_protocols)
    organizations = organizations.distinct if include_distinct
    
    return organizations
  end

  private

  def fetch_rights
    @super_user_orgs ||= Organization.includes(:super_users).where(super_users: {identity_id: @id}).references(:super_users).distinct
    @clinical_provider_orgs ||= Organization.includes(:clinical_providers).where(clinical_providers: {identity_id: @id}).references(:clinical_providers).distinct
  end

  def authorized_child_organizations(org_ids)
    # Extract IDs safely whether passed as Organization objects or integers
    ids = Array(org_ids).map { |org| org.is_a?(Organization) ? org.id : org }.compact
    
    if ids.empty?
      []
    else
      # Return objects to remain consistent with array concatenations above
      orgs = Organization.where(parent_id: ids).to_a
      orgs | authorized_child_organizations(orgs)
    end
  end
end
