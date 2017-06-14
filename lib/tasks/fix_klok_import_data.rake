# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

		change = prompt "Would you like to change the performer id and creator id for a specific performer id? (Y/N) "
		if change == "Y"
			old_performer_id = prompt "Enter performer id: "

			fulfillments = Fulfillment.where("klok_entry_id IS NOT NULL AND performer_id = ?", old_performer_id)
			no_of_fulfillments = fulfillments.count
			puts "There are " + no_of_fulfillments.to_s + " fulfillments with performer id " + old_performer_id
			
			if no_of_fulfillments > 0
				new_performer_id = prompt "Enter new performer id: "
				new_creator_id = prompt "Enter new creator id: "

				fulfillments.each do |fulfillment|
					fulfillment.update_attributes(performer_id: new_performer_id, creator_id: new_creator_id)
				end

				puts "The performer id and creator id are changed for all the " + no_of_fulfillments.to_s + " fulfillments"
			end	

		else
			puts "Exiting task...."

		end
	end
end