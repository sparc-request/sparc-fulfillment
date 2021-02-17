# Copyright © 2011-2020 MUSC Foundation for Research Development~
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
    organization_ids = @super_user_orgs + authorized_child_organizations(@super_user_orgs) + @clinical_provider_orgs

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
    ##This is a different version of the above "fulfillment_access_protocols" method, but without eager loading of un-needed relations.
    fetch_rights
    Protocol.joins(:sub_service_request).where(sub_service_requests: {organization_id: @super_user_orgs + authorized_child_organizations(@super_user_orgs) + @clinical_provider_orgs}).distinct
  end

  def authorized_billing_manager_protocols
    billing_manager_orgs ||= Organization.includes(:super_users).where(super_users: {identity_id: @id, billing_manager: true}).references(:super_users).distinct(:organizations)
    Protocol.joins(:sub_service_request).where(sub_service_requests: {organization_id: billing_manager_orgs + authorized_child_organizations(billing_manager_orgs)}).distinct
  end

  def authorized_billing_manager_protocols_allow_credit
    billing_manager_orgs ||= Organization.includes(:super_users).where(super_users: {identity_id: @id, billing_manager: true, allow_credit: true}).references(:super_users).distinct(:organizations)
    Protocol.joins(:sub_service_request).where(sub_service_requests: {organization_id: billing_manager_orgs + authorized_child_organizations(billing_manager_orgs)}).distinct
  end

  def fulfillment_organizations_with_protocols(include_distinct=true)
    # Optional distinct to save an additional sql query when not needed
    fetch_rights
    organizations = Organization.joins(:protocols).where(id: @super_user_orgs + authorized_child_organizations(@super_user_orgs) + @clinical_provider_orgs)
    if include_distinct
      organizations = organizations.distinct
    end
    return organizations
  end

  private

  def fetch_rights
    @super_user_orgs ||= Organization.includes(:super_users).where(super_users: {identity_id: @id}).references(:super_users).distinct(:organizations)
    @clinical_provider_orgs ||= Organization.includes(:clinical_providers).where(clinical_providers: {identity_id: @id}).references(:clinical_providers).distinct(:organizations)
  end

  def authorized_child_organizations(org_ids)
    org_ids = org_ids.compact
    if org_ids.empty?
      []
    else
      orgs = Organization.where(parent_id: org_ids)
      orgs | authorized_child_organizations(orgs.pluck(:id))
    end
  end

end
