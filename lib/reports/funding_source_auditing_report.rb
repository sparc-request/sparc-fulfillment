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

class FundingSourceAuditingReport < Report
  VALIDATES_PRESENCE_OF = [:title, :start_date, :end_date, :organizations, :protocols].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  require 'csv'

  def generate(document)
    start_date = Time.strptime(@params[:start_date], "%m/%d/%Y")
    end_date = Time.strptime(@params[:end_date], "%m/%d/%Y")
    @start_date = start_date.utc
    @end_date = end_date.tomorrow.utc - 1.second
    formatted_start_date = format_date(start_date)
    formatted_end_date = format_date(end_date)

    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    @organizations = IdentityOrganizations.new(@params[:identity_id]).fulfillment_organizations_with_protocols

    @sparc_protocol_ids = Protocol.where(id: @params[:protocols]).pluck(:sparc_id)

    CSV.open(document.path, "wb") do |csv|

      csv << ["Report Parameters:"]

      csv << ["Funding Source Changed From:", formatted_start_date, "Funding Source Changed To:", formatted_end_date]

      if @params[:organizations].map(&:to_i).sort == @organizations.map(&:id).sort
        csv << ["Organization(s):", "All Organizations"]
      else
        csv << ["Organization(s):", @params[:organizations].map{|org_id| Organization.find(org_id).name}.join(', ')]
      end

      if @params[:all_protocols_selected] == 'true'
        csv << ["Protocol(s):", "All Protocols"]
      else
        csv << ["Protocol(s):", @sparc_protocol_ids.join(', ')]
      end

      csv << [""]

      header = [
        "Protocol ID",
        "Request ID",
        "Status",
        "Short Title",
        "Proposal Funding Status",
        "Funding Start Date",
        "Funding Source",
        "Previous Funding Source",
        "Funding Source Change Date",
        "Primary PI",
        "Primary PI Affiliation",
        "Billing Business Manager(s)",
        "Core/Program",
        "Services",
        "Invoiced"
      ]
      header.insert(0, ENV['RMID_URL'].nil? ? "" : "RMID")
      csv << header

      protocols = Protocol.includes(
        :sparc_protocol,
        :pi,
        :sub_service_request,
        { line_items: [:fulfillments, { service: :organization }] }
      ).where(id: @params[:protocols])

      protocols_by_sparc_id = protocols.index_by(&:sparc_id)
      sparc_protocol_ids = protocols_by_sparc_id.keys

      audits = Sparc::Audit.where(auditable_type: "Protocol", auditable_id: sparc_protocol_ids, created_at: @start_date..@end_date, action: "update").select do |audit|
        audited_changes = YAML.load(audit.audited_changes)
        audited_changes.key?('funding_source')
      end

      if @params[:sort_by] == "Protocol ID"
        audits = audits.sort_by(&:auditable_id)
      else
        audits = audits.sort_by{ |audit| protocols_by_sparc_id[audit.auditable_id].pi.last_name }
      end

      if @params[:sort_order] == "DESC"
        audits.reverse!
      end

      audits.each do |audit|
        protocol = protocols_by_sparc_id[audit.auditable_id]
        funding_source_changes = YAML.load(audit.audited_changes)

        fulfillment_protocols = protocols.select{|p| p.sparc_id == audit.auditable_id}
        fulfillment_protocols.each do |fulfillment_protocol|
          fulfilled_services = []
          fulfilled_services.concat(fulfillment_protocol.fulfillments.includes(service: :organization))
          fulfilled_services.concat(fulfillment_protocol.procedures.includes(service: :organization).select{|procedure| procedure.completed_date != nil && procedure.billing_type == 'research_billing_qty'})

          fulfilled_services_grouped_by_org = fulfilled_services.group_by{|item| item.service.organization}

          fulfilled_services_grouped_by_org.each do |org, service_group|

            csv << [
              ENV['RMID_URL'] ? protocol.research_master_id : nil,
              protocol.sparc_protocol.id,
              fulfillment_protocol.sub_service_request.ssr_id,
              formatted_status(protocol),
              protocol.short_title,
              protocol.sparc_protocol&.funding_status&.humanize,
              protocol.sparc_protocol&.funding_start_date&.strftime("%m/%d/%Y"),
              funding_source_changes.dig("funding_source", -1)&.humanize,
              funding_source_changes.dig("funding_source", 0)&.humanize,
              format_date(audit.created_at),
              protocol.pi&.full_name,
              protocol.pi&.professional_org_lookup("institution"),
              protocol.billing_business_managers.map(&:full_name).join(', '),
              service_group.any? ? org.name : "",
              service_group.any? ? service_group.map{|s| s.service.name }.uniq.join(', ') : "",
              service_group.any?(&:invoiced) ? "Yes" : service_group.any? ? "No" : ""
            ]
          rescue => e
            Rails.logger.info "#"*20+" An error occured while processing organization #{org.id}: #{e.message}"
          end
        rescue => e
          Rails.logger.info "#"*20+" An error occured while processing fulfillment protocol #{fulfillment_protocol.id}: #{e.message}"
        end
      rescue => e
        Rails.logger.info "#"*20+" An error occured while processing protocol #{protocol.id}: #{e.message}"
      end
    end
  rescue => e
    Rails.logger.info "#"*20+" An error occured while generating the Funding Source Auditing Report: #{e.message}"
  end
end
