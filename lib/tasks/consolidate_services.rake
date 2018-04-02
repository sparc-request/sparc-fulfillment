# Copyright © 2011-2018 MUSC Foundation for Research Development~
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
      service      = Service.find(service_id)
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
