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

require 'csv'

namespace :data do
  desc 'Add fulfillments based on imported Klok spreadsheet'
  task add_fulfillments_from_klok: :environment do
    puts "This is a task to add fulfillments and associated data based on a csv import from Klok"
    puts "Please enter the full file path to the csv file you wish to import below"
    file_path = STDIN.gets.strip

    # The header conversion lambda converts the capitalized and spaced names of the headers into lowercase and separated by underscores
    parsed_csv = CSV.read(file_path, headers: true, encoding: 'iso-8859-1', converters: :all, :header_converters => lambda { |h| h.downcase.gsub(' ', '_')})
    
    while !parsed_csv
      puts "Unrecognized input"
      puts "Please enter the full file path to the csv file you wish to import below"
      parsed_csv = CSV.read(file_path, headers: true, encoding: 'iso-8859-1', converters: :all, :header_converters => lambda { |h| h.downcase.gsub(' ', '_')})
    end

    data = []
    item_count = 1 #Item count starts at 1 to account for the fact that the first row will be headers
    failed_item_count = 0
    successful_item_count = 0

    parsed_csv.each do |row|
      data << row.to_hash.symbolize_keys
    end

    data.each do |item|
      item_count += 1
      if item[:sparc_service_request_id].present?
        # This entire code block is intended to track down the specific fulfillment line item for the data given in the spreadsheet
        ids = item[:sparc_service_request_id].split('-', 2).map{|str| str.strip}
        ids[0] = ids[0].to_i 

        ssr = SubServiceRequest.where(protocol_id: ids[0], ssr_id: ids[1]).first

        unless ssr.present?
          failed_item_count += 1
          puts " - Row #{item_count}: failed due to being unable to find a sub service request based on the Sparc Service Request ID"

          next
        end
        
        matched_sparc_line_item = []
        sparc_line_items = Sparc::LineItem.where(sub_service_request: ssr.id)
        sparc_line_items.each do |sparc_line_item|
          if sparc_line_item.service.name.strip == item[:service_name].strip
            matched_sparc_line_item << sparc_line_item
          end
        end

        unless matched_sparc_line_item.present?
          failed_item_count += 1
          puts " - Row #{item_count}: failed due to being unable to find a Sparc Line Item"

          next
        end

        unless matched_sparc_line_item.count == 1
          failed_item_count += 1
          puts " - Row #{item_count}: failed due to multiple potential Sparc Line Items"

          next
        end

        line_item = LineItem.find_by(sparc_id: matched_sparc_line_item.first)

        unless line_item.present?
          failed_item_count += 1
          puts " - Row #{item_count}: failed due to being unable to find a Fulfillment Line Item"

          next
        end

        # Having found the line item, we now begin the process of creating the fulfillment entry.
        if item[:completed_by].present?

          identity = Identity.where(ldap_uid: item[:completed_by]).first

          if identity.present?
            funding_source = line_item.protocol.sparc_funding_source

            unless item[:date_fulfilled].present?
              failed_item_count += 1
              puts " - Row #{item_count}: failed due to not having Date Fulfilled filled out"

              next
            end

            unless item[:start_time].present? && item[:end_time].present?
              failed_item_count += 1
              puts " - Row #{item_count}: failed due to missing either the Start Time or End time"

              next
            end

            #NOTE:  This section was added because the csv files sent had a tendency to flip between year formats.  The following code gets the checks for which format is correct for parsing the given date_time and utilizes that for the remainder of the code.
            potential_fulfillment_date_1 = DateTime.strptime(item[:date_fulfilled], '%m/%d/%Y')
            potential_fulfillment_date_2 = DateTime.strptime(item[:date_fulfilled], '%m/%d/%y')
            fulfillment_date = ""

            if potential_fulfillment_date_1.year.between?(2000,2099)
              fulfillment_date = potential_fulfillment_date_1
            elsif potential_fulfillment_date_2.year.between?(2000,2099)
              fulfillment_date = potential_fulfillment_date_2
            else
              failed_item_count += 1
              puts " - Row #{item_count}: failed due to inability to compose a valid fulfillment date"

              next
            end


            fulfillment_time = ((Time.strptime(item[:end_time], '%I:%M %p') - Time.strptime(item[:start_time], '%I:%M %p'))/3600).round(2)

            begin
              service_cost = line_item.cost(funding_source, fulfillment_date)
            rescue StandardError => e
              failed_item_count += 1
              puts " - Row #{item_count}: failed due to being unable to find a pricing map for the given service and date."

              next
            end


            fulfillment = line_item.fulfillments.new(
              fulfilled_at: fulfillment_date.strftime('%m/%d/%Y'), 
              performer: identity, 
              service_id: matched_sparc_line_item.first.service.id, 
              service_name: matched_sparc_line_item.first.service.name, 
              service_cost: line_item.cost(funding_source, fulfillment_date), 
              funding_source: funding_source, 
              quantity: fulfillment_time
            )

            if item[:fulfillment_component].present?
              fulfillment.components_data = [item[:fulfillment_component]]
              fulfillment.components.new(component: fulfillment.components_data.first)
            end

            if item[:fulfillment_notes].present?
              fulfillment.notes.new(comment: item[:fulfillment_notes], identity: identity)
            end

            if fulfillment.save
              successful_item_count += 1
            else
              failed_item_count += 1
              puts " - Row #{item_count}: has all necessary data but failed to save.  Have developer check server log."

              next
            end
          else
            failed_item_count += 1
            puts " - Row #{item_count}: failed due to finding no person with the Net ID #{item[:completed_by]}"

            next
          end
        else
          failed_item_count += 1
          puts " - Row #{item_count}: failed due to 'Completed By' column being blank"

          next
        end
      else
        failed_item_count += 1
        puts " - Row #{item_count}: failed due to not having a Sparc Service Request ID."

        next
      end
    end

    if failed_item_count == 0
      puts "**All Tasks Complete**  Successfully created #{successful_item_count} records."
    else
      puts "**All Tasks Complete**  Successfully created #{successful_item_count} records.  A total of #{failed_item_count} were unusable.  Please review the failure notes above and send a revised CSV to enter in the data." 
    end 
  end
end
