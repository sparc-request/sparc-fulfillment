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

namespace :data do
  desc "Fix Missing Subsidy, and Funding Source Info on Procedures"
  task fix_missing_funding_and_subsidy: :environment do

    CSV.open("tmp/fix_funding_and_subsidy_info_report.csv", "wb") do |csv|

      @errors = []

      #Looking for procedures with missing subsidy percent info:
      puts "Finding protocols with Subsidy, and grabbing procedures and fulfillments under them that are missing a subsidy percent"
      protocols_with_subsidy = Protocol.joins(:subsidy)
      bar1 = ProgressBar.new(protocols_with_subsidy.size)
      procedures_missing_subsidies = []
      fulfillments_missing_subsidies = []

      protocols_with_subsidy.each do |protocol|
        protocol.procedures.complete.where(percent_subsidy: nil).each do |procedure|
          procedures_missing_subsidies << procedure
          procedure.update_attributes(percent_subsidy: protocol.percent_subsidy)
        end
        protocol.fulfillments.where(percent_subsidy: nil).each do |fulfillment|
          fulfillments_missing_subsidies << fulfillment
          fulfillment.update_attributes(percent_subsidy: protocol.percent_subsidy)
        end

        bar1.increment!
      end


      #Looking for procedures with missing funding source info:
      puts "Finding Procedures with missing funding source"
      procedures_missing_funding_source = []
      bar2 = ProgressBar.new(Procedure.complete.where(funding_source: nil).count)

      Procedure.complete.where(funding_source: nil).each do |procedure|
        procedures_missing_funding_source << procedure
        procedure.update_attributes(funding_source: procedure.protocol.sparc_funding_source)
        bar2.increment!
      end


      # Looking for fulfillments with missing funding source info:
      puts "Finding Fulfillments with missing funding source"
      fulfillments_missing_funding_source_count = Fulfillment.where(funding_source: nil).count
      bar3 = ProgressBar.new(fulfillments_missing_funding_source_count)

      Fulfillment.includes(:protocol).where(funding_source: nil).find_each do |fulfillment|
        protocol = fulfillment.protocol
        if protocol
          fulfillment.update_attributes(funding_source: protocol.sparc_funding_source)
        else
          @errors << ["Fulfillment: #{fulfillment.id}", "Has No Protocol"]
        end
        bar3.increment!
      end

      puts "Cleaning up incomplete procedures that should not have funding source"
      Procedure.non_complete.where.not(funding_source: nil).update_all(funding_source: nil)
      puts "Done"

      puts "Cleaning up incomplete procedures that should not have subsidy"
      Procedure.non_complete.where.not(percent_subsidy: nil).update_all(percent_subsidy: nil)
      puts "Done"


      puts "Generating Report CSV"

      procedures_missing_both = procedures_missing_funding_source & procedures_missing_subsidies
      procedures_missing_only_funding_source = procedures_missing_funding_source - procedures_missing_subsidies
      procedures_missing_only_subsidies = procedures_missing_subsidies - procedures_missing_funding_source


      csv << ["Complete Procedures Missing Both Subsidy, and Funding Source"]
      csv << ["Procedure ID:", "ProtocolID/Request ID:", "Protocol Short Title:", "Protocol Funding Source:", "Request Status:", "Protocol Primary PI:"]
      procedures_missing_both.each do |procedure|
        protocol = procedure.protocol
        csv << [procedure.id, protocol.srid, protocol.short_title, protocol.sparc_funding_source, protocol.sub_service_request.status, protocol.pi.full_name]
      end

      csv << ["Complete Procedures Missing Only Subsidy"]
      csv << ["Procedure ID:", "ProtocolID/Request ID:", "Protocol Short Title:", "Protocol Funding Source:", "Request Status:", "Protocol Primary PI:"]
      procedures_missing_only_subsidies.each do |procedure|
        protocol = procedure.protocol
        csv << [procedure.id, protocol.srid, protocol.short_title, protocol.sparc_funding_source, protocol.sub_service_request.status, protocol.pi.full_name]
      end

      csv << ["Complete Procedures Missing Only Funding Source"]
      csv << ["Procedure ID:", "ProtocolID/Request ID:", "Protocol Short Title:", "Protocol Funding Source:", "Request Status:", "Protocol Primary PI:"]
      procedures_missing_only_funding_source.each do |procedure|
        protocol = procedure.protocol
        csv << [procedure.id, protocol.srid, protocol.short_title, protocol.sparc_funding_source, protocol.sub_service_request.status, protocol.pi.full_name]
      end



      csv << ["Fulfillments Missing Subsidy"]
      csv << ["Fulfillment ID:", "ProtocolID/Request ID:", "Protocol Short Title:", "Protocol Funding Source:", "Request Status:", "Protocol Primary PI:"]
      fulfillments_missing_subsidies.each do |fulfillment|
        protocol = fulfillment.protocol
        csv << [fulfillment.id, protocol.sub_service_request.ssr_id, protocol.short_title, protocol.sparc_funding_source, protocol.sub_service_request.status, protocol.pi.full_name]
      end

      csv << ["Fulfillments Missing Funding Source Fixed:", fulfillments_missing_funding_source_count]

      @errors.each do |error|
        csv << ["Error:", error.first, error.last]
      end

      puts "Report Complete"

    end

  end
end
