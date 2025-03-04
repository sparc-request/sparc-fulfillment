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

    # example klok file headers
    # Location,SPARC Service Request ID,Service Name,Date Fulfilled,Start Time,End Time,Completed By,Fulfillment Component,Fulfillment Notes

    def add_failed_item failed_items, row, error
      row['Error'] = error
      failed_items << row
    end

    def add_successful_item successful_items, row
      successful_items << row
    end

    parsed_csv = nil
    file_failed = false # additional message if filename invalid

    puts "This is a task to add fulfillments and associated data based on a csv import from Klok"
    
    while !parsed_csv
      puts "Unrecognized input" if file_failed
      puts "Please enter the filename to the csv file (in tmp folder) you wish to import below"
      filename = STDIN.gets.strip
      # The header conversion lambda converts the capitalized and spaced names of the headers into lowercase and separated by underscores
      parsed_csv = CSV.read(Rails.root.join("tmp", filename), headers: true, converters: :all, :header_converters => lambda { |h| h.downcase.gsub(' ', '_')})

      file_failed = true if !parsed_csv # set this so the additional message can be displayed
    end

    data = []
    item_count = 1 # item count starts at 1 to account for the fact that the first row will be headers

    failed_items = CSV.open(Rails.root.join("tmp/klok_failed.csv"), "wb")
    failed_items << ["Location", "SPARC Service Request ID", "Service Name", "Date Fulfilled", "Start Time", "End Time", "Completed By", "Fulfillment Component", "Fulfillment Notes", "Error"]

    successful_items = CSV.open(Rails.root.join("tmp/klok_successful.csv"), "wb")
    successful_items << ["Location", "SPARC Service Request ID", "Service Name", "Date Fulfilled", "Start Time", "End Time", "Completed By", "Fulfillment Component", "Fulfillment Notes"]

    parsed_csv.each do |row|
      item_count += 1
      if row["sparc_service_request_id"].present?
        # This entire code block is intended to track down the specific fulfillment line item for the data given in the spreadsheet
        ids = row["sparc_service_request_id"].split('-', 2)
        ids[0] = ids[0].to_i 

        ssr = SubServiceRequest.where(protocol_id: ids[0], ssr_id: ids[1]).first

        unless ssr.present?
          add_failed_item failed_items, row, "Couldn't find SSR for Protocol #{ids[0]}, SSR #{ids[1]}"
          next
        end
        
        matched_sparc_line_item = []
        sparc_line_items = Sparc::LineItem.where(sub_service_request: ssr.id)
        sparc_line_items.each do |sparc_line_item|
          if sparc_line_item.service.name == row["service_name"]
            matched_sparc_line_item << sparc_line_item
          end
        end

        unless matched_sparc_line_item.present?
          add_failed_item failed_items, row, "Couldn't find SPARC line item"
          next
        end

        unless matched_sparc_line_item.count == 1
          add_failed_item failed_items, row, "Multiple potential line items"
          next
        end

        line_item = LineItem.find_by(sparc_id: matched_sparc_line_item.first)

        unless line_item.present?
          add_failed_item failed_items, row, "Couldn't find CWF line item"
          next
        end

        # Having found the line item, we now begin the process of creating the fulfillment entry.
        if row["completed_by"].present?

          split_name = row["completed_by"].split(" ", 2)
          potential_identities = Identity.where(first_name: split_name[0], last_name: split_name[1])

          if potential_identities.present?
            if potential_identities.count == 1
              funding_source = line_item.protocol.sparc_funding_source

              unless row["date_fulfilled"].present?
                add_failed_item failed_items, row, "No date fulfilled present"
                next
              end

              unless row["start_time"].present? && row["end_time"].present?
                add_failed_item failed_items, row, "Missing either start or end time"
                next
              end

              fulfillment_date = DateTime.strptime("#{row["date_fulfilled"]}", '%m/%d/%y')
              fulfillment_time = Time.strptime(row["end_time"], '%I:%M %p') - Time.strptime(row["start_time"], '%I:%M %p')

              fulfillment = line_item.fulfillments.new(fulfilled_at: fulfillment_date.strftime('%m/%d/%Y'), performer: potential_identities.first, service_id: matched_sparc_line_item.first.service.id, service_name: matched_sparc_line_item.first.service.name, service_cost: line_item.cost(funding_source, fulfillment_date), funding_source: funding_source, quantity: fulfillment_time)

              if row["fulfillment_component"].present?
                fulfillment.components_data = [row["fulfillment_component"]]
              end

              if row["fulfillment_notes"].present?
                fulfillment.notes.new(comment: row["fulfillment_notes"], identity: potential_identities.first)
              end

              if fulfillment.save
                add_successful_item successful_items, row
              else
                add_failed_item failed_items, row, "Fulfillment save failed, #{fulfillment.errors.full_messages.join(', ')}"
                next
              end
            else
              add_failed_item failed_items, row, "#{potential_identities.count} people with the same name as the person listed in the 'Completed By' column"
              next
            end
          else
            add_failed_item failed_items, row, "No person with the name provided in the 'Completed By' column"
            next
          end 
        else
          add_failed_item failed_items, row, "'Completed By' column is blank"
          next
        end
      else
        add_failed_item failed_items, row, "No SSR ID"
        next
      end
    end

    failed_items.close
    successful_items.close

    failed_items_count = CSV.read(Rails.root.join("tmp/klok_failed.csv")).count
    successful_items_count = CSV.read(Rails.root.join("tmp/klok_successful.csv")).count

    if failed_items_count == 0
      puts "**All Tasks Complete**  Successfully created #{successful_items_count} records."
    else
      puts "**All Tasks Complete**  Successfully created #{successful_items_count} records.  A total of #{failed_items_count} were unusable. Check tmp/klok_failed.csv for more details"
    end 

  end
end
