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

  require 'csv'

  def generate(document)

    @start_date = parse_date(@params[:start_date])
    @end_date   = parse_date(@params[:end_date])

    update_document_attributes(document)

    protocols = Protocol.includes(:project_roles).where(id: @params[:protocols])

    CSV.open(document.path, "wb") do |csv|

      audits = fetch_audits(protocols)

      write_csv_title_and_date_range(csv)

      write_csv_header(csv)

      write_csv_rows(csv, audits, protocols)
    end
  end

  private

  def fetch_audits(protocols)
    protocol_ids = protocols.pluck(:sparc_id)
    audits = Sparc::Audit
          .where(auditable_type: "Protocol", auditable_id: protocol_ids)
          .where(action: "update")
          .where('audited_changes LIKE ? AND audited_changes NOT LIKE ?', '%funding_source%', '%additional_funding_source%')
          .includes(auditable: { line_items: { service: :organization } })
    audits
  end

  def parse_date(date_str)
    Time.strptime(date_str, "%m/%d/%Y").utc
  end

  def update_document_attributes(document)
    document.update_attributes(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")
  end

  def write_csv_title_and_date_range(csv)
    csv << ["Title:", @params[:title]]
    csv << ["From:", format_date(@start_date), "To:", format_date(@end_date)]
    csv << [""]
  end

  def write_csv_header(csv)
    header = [
      "",
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
    header.insert(1, ENV['RMID_URL'].nil? ? "" : "RMID")
    csv << header
  end

  def write_csv_rows(csv, audits, protocols)
    protocol_ids = audits.map(&:auditable_id)
    protocols = protocols.index_by(&:sparc_id)

    if @params[:sort_by] == "Protocol ID"
      audits = audits.sort_by { |audit| audit.auditable_id }
    else
      audits = audits.sort_by { |audit| protocols[audit.auditable_id]&.pi&.last_name }
    end

    audits.reverse! if @params[:sort_order] == "DESC"

    grouped_line_items = Hash.new { |hash, key| hash[key] = [] }

    audits.each do |audit|
      protocol = protocols[audit.auditable_id]

      next if protocol.nil?

      funding_source_changes = YAML.load(audit.audited_changes)
      next unless funding_source_changes["funding_source"]

      next unless @params[:organizations].include?(protocol.organization.id.to_s)

      line_items = protocol.line_items
      next if line_items.empty?

      line_items.each do |line_item|
        organization = line_item.service.organization
        grouped_line_items[organization] << line_item
      end

      grouped_line_items.each do |organization, line_items|
        csv << [
          "",
          ENV['RMID_URL'] ? protocol.research_master_id : nil,
          protocol.sparc_protocol.id,
          protocol.sub_service_request.ssr_id,
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
          organization.name,
          line_items.map { |li| li.service.name }.uniq.join(', '),
          protocol.fulfillments.any?(&:invoiced?) || protocol.procedures.any?(&:invoiced?) ? "Yes" : "No"
        ]
      end
    end
  rescue StandardError => e
    Rails.logger.error("#" * 50 + "#{e.message}")
  end
end
