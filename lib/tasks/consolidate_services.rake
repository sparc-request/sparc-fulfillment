namespace :data do 
	desc 'Replace the first service with the second service'
	task consolidate_services: :environment do

		def main
			id1, id2 = get_user_input

			if !(id1.nil? || id2.nil?)
				puts "This will change the Service ID of Procedures with Service ID = #{id1} to Service ID = #{id2}. Is this correct? Y/N?: "
				ok_with_values = STDIN.gets.chomp

				if "Yes".casecmp(ok_with_values) || "Y".casecmp(ok_with_values)
					update_procedures(id1, id2)
				else
					puts "Exiting rake task."
				end
			end
		end

		def get_user_input
			puts "What is the ID of the service to be replaced?: "
			service_1_id = Integer( STDIN.gets.chomp ) rescue nil

			puts "What is the ID of the new service?: "
			service_2_id = Integer( STDIN.gets.chomp ) rescue nil

			return service_1_id, service_2_id
		end

		def update_procedures(old_service_id, new_service_id)
			procs = Procedure.where(service_id: old_service_id)
			size  = procs.count

			procs.update_all("service_id = #{new_service_id}")

			puts "The Service ID of #{size} Procedure(s) has been updated from #{old_service_id} to #{new_service_id}."
		end

		main
	end
end