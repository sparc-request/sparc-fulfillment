# Copyright © 2011-2024 MUSC Foundation for Research Development~
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
  VALIDATES_PRESENCE_OF = [:title, :start_date, :end_date, :protocols, :organizations].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  SORT_BY_PROTOCOL_ID = "Protocol ID"
  SORT_ORDER_DESC = "DESC"
  AUDITABLE_TYPE_PROTOCOL = "Protocol"
  AUDIT_ACTION_UPDATE = "update"
  AUDIT_CHANGES_FUNDING_SOURCE = "%funding_source%"

  def generate(document)
    @start_date = parse_date(@params[:start_date])
    @end_date   = parse_date(@params[:end_date]).tomorrow.utc - 1.second

    update_document_attributes(document)

    CSV.open(document.path, "wb") do |csv|
      protocols = fetch_protocols

      sort_protocols(protocols)

      write_csv_header(csv)

      audits = fetch_audits

      write_csv_rows(csv, audits)
    end
  end

  private

  def parse_date(date_str)
    Time.strptime(date_str, "%m/%d/%Y").utc
  end

  def update_document_attributes(document)
    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")
  end

  def fetch_protocols
    Protocol.where(organization: @params[:organizations], id: @params[:protocols])
  end

  def sort_protocols(protocols)
    if @params[:sort_by] == SORT_BY_PROTOCOL_ID
      protocols = protocols.order(:sparc_id)
    else
      protocols = protocols.sort_by { |protocol| protocol.pi.last_name }
    end

    protocols.reverse! if @params[:sort_order] == SORT_ORDER_DESC
  end

  def write_csv_header(csv)
    header = %w[Protocol_ID Request_ID Short_Title Previous_Funding_Source Proposal_Funding_Status Funding_Source Funding_Start_Date Status Primary_PI Primary_PI_Affiliation Billing_Business_Manager(s) Core/Program_Affected Services_Affected Quantity_Completed Total_Cost Invoiced]
    header.insert(2, 'RMID') if ENV.fetch('RMID_URL'){nil}
    header.map!(&:humanize)
    csv << header
  end

  def fetch_audits
    Sparc::Audit.where(auditable_type: AUDITABLE_TYPE_PROTOCOL)
                .where(action: AUDIT_ACTION_UPDATE)
                .where('created_at >= ? AND created_at <= ?', @start_date, @end_date)
                .where('audited_changes LIKE ?', AUDIT_CHANGES_FUNDING_SOURCE)
  end

  def write_csv_rows(csv, audits)
    audits.each do |audit|
      protocol = Protocol.find_by(sparc_id: audit.auditable_id)
      next if protocol.nil?
      funding_source_changes = YAML.load(audit.audited_changes)

      next unless funding_source_changes["funding_source"]

      csv << [
        protocol.try(:srid),
        protocol.try(:sub_service_request).try(:ssr_id),
        ENV.fetch('RMID_URL', nil) ? protocol.research_master_id : nil,
        protocol.short_title,
        funding_source_changes["funding_source"][0],
        protocol.sparc_protocol.funding_status,
        funding_source_changes["funding_source"][1],
        protocol.sparc_protocol.funding_start_date,
        protocol.status,
        protocol.pi&.full_name,
        protocol.pi&.professional_org_lookup("institution"),
        protocol.billing_business_managers.map(&:full_name).join(','),
        protocol.organization.name,
        protocol.line_items.map(&:service).map(&:name).join(','),
        protocol.fulfillments.sum(&:quantity),
        protocol.fulfillments.sum(&:total_cost),
        protocol.fulfillments.map { |fulfillment| fulfillment.invoiced? ? "Yes" : "No" }.join(',')
      ]
    end
  end
end
