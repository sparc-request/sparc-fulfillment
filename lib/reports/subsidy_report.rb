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

class SubsidyReport < Report
  VALIDATES_PRESENCE_OF = [:title, :sort_by, :sort_order].freeze
  VALIDATES_NUMERICALITY_OF = [].freeze

  require 'csv'

  # The memory-heavy protocols_for_date_range method has been completely removed!

  def total_cost(protocol, invoiced)
    fulfillments_scope = protocol.fulfillments
    procedures_scope   = protocol.procedures.where.not(completed_date: nil)

    if invoiced
      fulfillments_scope = fulfillments_scope.where(invoiced: true)
      procedures_scope   = procedures_scope.where(invoiced: true)
    end

    # `.to_a.sum` evaluates virtual attributes in Ruby memory
    fulfillments_total = fulfillments_scope.to_a.sum(&:total_cost)
    procedures_total   = procedures_scope.to_a.sum(&:service_cost)

    fulfillments_total + procedures_total
  end

  def generate(document)
    no_dates = ((@params[:start_date] == "") && (@params[:end_date] == ""))
    permitted_protocols = @params[:permissions] || []

    base_protocols = Protocol.joins(sub_service_request: :subsidy)
                             .where(id: permitted_protocols)

    if !no_dates
      @start_date = (@params[:start_date] == "") ? Time.strptime("1/01/2012", "%m/%d/%Y").utc : Time.strptime(@params[:start_date], "%m/%d/%Y").utc
      @end_date = (@params[:end_date] == "") ? Time.now.utc : Time.strptime(@params[:end_date], "%m/%d/%Y").tomorrow.utc - 1.second
      
      base_protocols = base_protocols.where(subsidies: { approved_at: @start_date..@end_date })
    end

    document.update(content_type: 'text/csv', original_filename: "#{@params[:title]}.csv")

    CSV.open(document.path, 'wb') do |csv|
      if !no_dates
        csv << ["From", format_date(@start_date), "To", format_date(@end_date)]
        csv << [""]
      end

      # Memory-safe sorting using PI and ID's
      protocols_for_sorting = base_protocols.includes(:pi)

      if @params[:sort_by] == "Protocol ID"
        protocols_for_sorting = protocols_for_sorting.sort_by(&:sparc_id)
      else
        protocols_for_sorting = protocols_for_sorting.sort_by{ |protocol| protocol.pi&.last_name.to_s }
      end

      protocols_for_sorting.reverse! if @params[:sort_order] == "DESC"
      
      # Extract only ID's for memory
      sorted_protocol_ids = protocols_for_sorting.map(&:id)

      header = []
      header << "Protocol ID"
      header << "Request ID"
      header << "RMID" if ENV.fetch('RMID_URL'){nil}
      header << "Short Title"
      header << "Funding Source"
      header << "Status"
      header << "Primary PI"
      header << "Primary PI Affiliation"
      header << "Start Date"
      header << "End Date"
      header << "Approved Subsidy Total Amount"
      header << "Approved Subsidy %"
      header << "Subsidy Approval Date"
      header << "Total Fulfilled Amount ($)"
      header << "Total Invoiced Amount ($)"
      header << "Subsidy Residual"
 
      csv << header

      # Load one protocol's associations at a time
      sorted_protocol_ids.each do |protocol_id|
        protocol = Protocol.includes(:pi, :sparc_protocol, sub_service_request: :subsidy).find(protocol_id)
        
        total_fulfilled = total_cost(protocol, false)
        ssr = protocol.sub_service_request
        subsidy = ssr.subsidy
        pi = protocol.pi

        data = []
        data << protocol.sparc_id
        data << ssr.ssr_id
        data << protocol.research_master_id if ENV.fetch('RMID_URL'){nil}
        data << protocol.sparc_protocol.short_title
        data << protocol.sparc_protocol.funding_source
        data << formatted_status(protocol)
        data << (pi ? pi.full_name : nil)
        data << (pi ? [pi.professional_org_lookup("institution"), pi.professional_org_lookup("college"),
                                pi.professional_org_lookup("department"), pi.professional_org_lookup("division")].compact.join("/") : nil)
        data << format_date(protocol.sparc_protocol.start_date)
        data << format_date(protocol.sparc_protocol.end_date)
        data << display_cost(subsidy.subsidy_committed)
        data << "#{subsidy.percent_subsidy * 100}%" # Syntax fix applied here
        data << format_date(subsidy.approved_at)
        data << display_cost(total_fulfilled)
        data << display_cost(total_cost(protocol, true))
        data << display_cost(subsidy.subsidy_committed - total_fulfilled)

        csv << data
      end
    end
  end
end