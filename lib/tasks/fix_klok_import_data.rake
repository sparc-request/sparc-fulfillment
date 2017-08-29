# Copyright © 2011-2017 MUSC Foundation for Research Development~
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
  desc "Fix Klok import data"
  task fix_klok_import_data: :environment do

    def prompt(*args)
      print(args)
      STDIN.gets.strip
    end

    def is_integer(number)
      true if Integer(number) rescue false
    end

    def exit_block(message)
      puts message
      puts "Exiting task...."
      exit
    end

    change = prompt "Would you like to change the performer id and creator id for a specific performer id? (Y/N) "
    if change == "N"
      exit_block("")
    end

    old_performer_id = prompt "Enter performer id: "
    if is_integer(old_performer_id) == false
      exit_block("Invalid performer id")
    end

    fulfillments = Fulfillment.where("klok_entry_id IS NOT NULL AND performer_id = ?", old_performer_id)
    no_of_fulfillments = fulfillments.count
    puts "There are " + no_of_fulfillments.to_s + " fulfillments with performer id " + old_performer_id

    if no_of_fulfillments == 0
      exit_block("")
    end

    new_performer_id = prompt "Enter new performer id: "
    if is_integer(new_performer_id) == false
      exit_block("Invalid performer id")
    end

    new_creator_id = prompt "Enter new creator id: "
    if is_integer(new_creator_id) == false
      exit_block("Invalid creator id")
    end

    CSV.open("tmp/fix_klok_import_data_#{Time.now.strftime('%m%d%Y%H%M%S')}.csv}", "wb") do |csv|
      fulfillments.each do |fulfillment|
        begin
          csv << ["Fulfillment ID: #{fulfillment.id}", "Protocol ID: #{fulfillment.line_item.protocol.sparc_id}", "Existing performer id: #{fulfillment.performer_id}", "New performer id: #{new_performer_id}", "Existing creator id: #{fulfillment.creator_id}", "New creator id: #{new_creator_id}" ]
          fulfillment.update_attributes(performer_id: new_performer_id, creator_id: new_creator_id)
        rescue Exception => e
          puts "Error with fulfillment id #{fulfillment.id}, Message: #{e.message}"
          next
        end
      end
    end

  end
end
