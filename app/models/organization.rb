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

class Organization < SparcDbBase
  belongs_to :parent, class_name: "Organization"
  has_many :sub_service_requests
  has_many :pricing_setups
  has_many :super_users
  has_many :clinical_providers
  has_many :children, class_name: "Organization", foreign_key: :parent_id

  has_many :protocols, through: :sub_service_requests

  has_many :services,
            -> {where(is_available: true)}

  has_many :all_services, class_name: "Service" # include services regardless of is_available

  has_many :non_process_ssrs_children,
            -> { where(process_ssrs: false) },
            class_name: "Organization",
            foreign_key: :parent_id

  # Returns this organization's pricing setup that is effective on a given date.
  def effective_pricing_setup_for_date(date=Date.today)
    if self.pricing_setups.blank?
      raise ArgumentError, "Organization has no pricing setups" if self.parent.nil?
      return self.parent.effective_pricing_setup_for_date(date)
    end

    current_setups = self.pricing_setups.select { |x| x.effective_date.to_date <= date.to_date }

    raise ArgumentError, "Organization has no current effective pricing setups" if current_setups.empty?
    sorted_setups = current_setups.sort { |lhs, rhs| lhs.effective_date <=> rhs.effective_date }
    pricing_setup = sorted_setups.last

    return pricing_setup
  end

  def inclusive_child_services(scope, is_available=true)
    (is_available ? services : all_services).
      send(scope).
      to_a.
      push(all_child_services(scope, is_available)).
      flatten.
      sort_by(&:name)
  end

  def all_child_organizations
    [
      children,
      children.map(&:all_child_organizations)
    ].flatten
  end

  def child_orgs_with_protocols
    organizations = all_child_organizations
    organizations_with_protocols = []
    organizations.flatten.uniq.each do |organization|
      if organization.protocols.any?
        organizations_with_protocols << organization
      end
    end
    organizations_with_protocols.flatten.uniq
  end

  # NOT SURE WHAT THIS IS TRYING TO ACCOMPLISH
  def all_child_organizations_with_non_process_ssrs
    [
      non_process_ssrs_children,
      non_process_ssrs_children.map(&:all_child_organizations_with_non_process_ssrs)
    ].flatten
  end

  def all_child_services(scope, is_available=true)
    all_child_organizations_with_non_process_ssrs.map { |child| child.send(is_available ? :services : :all_services).send(scope) }
  end
end
