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

module ProtocolHelper
  def protocol_label(protocol)
    protocol.label.truncate(50)
  end

  def request_label(protocol)
    protocol.sub_service_request.label.truncate(50)
  end

  def dashboard_link(protocol)
    content_tag(:a, href: protocol.sparc_uri, target: :blank, class: 'btn btn-light mr-2', title: t(:protocol)[:admin_portal_link_tooltip], aria: { expanded: 'false' }) do
      icon('fas', 'link mr-2') + t('protocols.sparc_link')
    end
  end

  def formatted_status protocol
    if protocol.status.present?
      t(:sub_service_request)[:statuses][protocol.status.to_sym]
    else
      '-'
    end
  end

  def format_organization_name(ssr)
    "#{ssr.organization.abbreviation} Cost"
  end

  def effective_current_total sub_service_request
    ssr = Sparc::SubServiceRequest.find(sub_service_request.id)
    ssr.set_effective_date_for_cost_calculations
    total = (ssr.direct_cost_total / 100.0)
    ssr.unset_effective_date_for_cost_calculations

    return total
  end

  def effective_study_cost protocol
    total = 0.0
    protocol.service_requests.where.not(status: 'first_draft').each do |sr|
      sr.sub_service_requests.each do |ssr|
        total += effective_current_total(ssr)
      end
    end

    if(ENV.fetch('USE_INDIRECT_COST') == 'true')
      total = total * (1 + protocol.sparc_protocol.indirect_cost_rate.to_f/100)
    end

    total
  end

  def formatted_owner protocol
    if protocol.owner.present?
      protocol.owner.full_name
    else
      '-'
    end
  end

  def formatted_requester protocol
    if protocol.sub_service_request.present? && protocol.sub_service_request.service_request.present? && protocol.service_requester.present?
      protocol.service_requester.full_name
    else
      '-'
    end
  end

  def formatted_study_schedule_report protocol
    content_tag :button, class: 'btn btn-secondary study-schedule-report report-button', data: { url: reports_path(report_type: 'study_schedule_report', title: t('reports.study_schedule_report'), documentable_id: protocol.id, documentable_type: Protocol.name) } do
      icon('fas', 'file-download mr-2') + t('actions.export')
    end
  end

  def formatted_coordinators(coordinators)
    if coordinators.any?
      content_tag :div, class: 'dropdown' do
        content_tag(:button, 'Coordinators', type: 'button', class: 'btn btn-light dropdown-toggle', data: { toggle: 'dropdown', boundary: 'window' }, aria: { expanded: 'false' }) +
        content_tag(:div, class: 'dropdown-menu', id: 'coordinator-menu') do
          coordinators.map do |co|
            content_tag(:p, co, class: 'dropdown-item')
          end.join('').html_safe
        end
      end
    end
  end

  def arm_per_participant_line_items_by_core arm, consolidated=false
    line_items = arm.line_items
    if consolidated && Sparc::Arm.where(id: arm.sparc_id).any?
      sparc_arm = Sparc::Arm.where(id: arm.sparc_id).first
      line_items += sparc_arm.line_items_visits.select{ |liv| liv.line_item.sub_service_request_id != arm.protocol.sub_service_request_id} # add pppv line items that aren't already in cwf
    end

    line_items.group_by{|li| li.service.organization}
  end

  def consolidated_one_time_fee_line_items protocol
    line_items = protocol.one_time_fee_line_items
    if Sparc::Protocol.where(id: protocol.sparc_id).any?
      sparc_protocol = Sparc::Protocol.where(id: protocol.sparc_id).first
      sparc_protocol.service_requests.each do |sr|
        line_items += sr.line_items.one_time_fee.select{ |li| li.sub_service_request_id != protocol.sub_service_request_id } # add otf line items that aren't already in cwf
      end
    end

    line_items
  end
end
