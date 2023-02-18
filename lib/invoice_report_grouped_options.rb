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

class InvoiceReportGroupedOptions
  include ActionView::Helpers::TagHelper

  def initialize(org_or_service, type)
    @organizations = org_or_service if type == 'organization'
    @services = org_or_service if type == 'service'
  end

  def collect_grouped_options
    groups = @organizations.
      sort { |lhs, rhs| lhs.name <=> rhs.name }.
      group_by(&:type)
    options = ["Institution", "Provider", "Program", "Core"].map do |type|
      next unless groups[type].present?
      [type.pluralize, extract_name_and_id(groups[type])]
    end
    options.compact
  end

  def collect_grouped_options_services
    services = @services.sort { |lhs, rhs| lhs.name <=> rhs.name }

    service_options = []
    services.each do |service|
      inactive_indicator = service.is_available ? '' : '<small class="text-danger ml-1"><em>Inactive</em></small>'
      service_options << [{'data-content': service.name + inactive_indicator}, service.id]
    end

    service_options.compact
  end

  private

  def extract_name_and_id(orgs)
    org_options = []
    orgs.each do |org|
      inactive_indicator = org.is_available ? '' : '<small class="text-danger ml-1"><em>Inactive</em></small>'
      org_options << [{'data-content': org.name + inactive_indicator}, org.id]
    end
    org_options
  end
end
