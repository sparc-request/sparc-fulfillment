namespace :data do 
	desc 'Replace the first service with the second service'
	task consolidate_services: :environment do

		def main
			service_1_id, service_2_id = get_user_input

			#Make sure that both
			if !(service_1_id.nil? || service_2_id.nil?) && (service_1_id > 0 && service_2_id > 0)

				if services_can_be_swapped?(service_1_id, service_2_id)
					puts "This will change the Service ID of Incomplete and Unstarted Procedures with Service ID = #{service_1_id} to Service ID = #{service_2_id}. Is this correct? Y/N?"
					ok_with_values = STDIN.gets.chomp

					if "Yes".casecmp(ok_with_values).zero? || "Y".casecmp(ok_with_values).zero?
						update_procedures(service_1_id, service_2_id)
					elsif "No".casecmp(ok_with_values).zero? || "N".casecmp(ok_with_values).zero?
						puts "Service IDs will not be changed."
					else
						puts "Invalid values were entered."
					end
				else
					puts "These services are associated with different organizations and can't be swapped."
				end
			else
				puts "Invalid values were entered."
			end

			puts "Exiting rake task."
		end

		def get_user_input
			puts "What is the ID of the service to be replaced?"
			service_1_id = Integer( STDIN.gets.chomp ) rescue nil

			puts "What is the ID of the new service?"
			service_2_id = Integer( STDIN.gets.chomp ) rescue nil

			return service_1_id, service_2_id
		end

		def services_can_be_swapped?(service_1_id, service_2_id)
			get_process_ssr_org(service_1_id) == get_process_ssr_org(service_2_id)
		end

		def get_process_ssr_org(service_id)
			service 		 = Service.find(service_id)
			organization = service.organization

			while !organization.process_ssrs
				organization = organization.parent
			end

			organization
		end

		def update_procedures(old_service_id, new_service_id)
			procs = Procedure.where(service_id: old_service_id, status: ["unstarted", "incomplete"])
			
			puts "The Service ID of #{procs.count} Procedure(s) is being updated from #{old_service_id} to #{new_service_id}."
			procs.update_all(service_id: new_service_id)
		end

		main
	end
end