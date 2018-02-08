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

task :fix_procedure_data => :environment do

  def prompt(*args)
      print(*args)
      STDIN.gets.strip
  end

  def create_core_hash(new_core_ids)
    service_names = {}

    new_core_ids.each do |id|
      names = Service.where(organization_id: id).map(&:name)
      service_names[id] = names
    end

    service_names
  end

  def fix_procedures(service_names, old_procedures)
    service_names.each do |core_id, service_names|
      old_procedures.each do |procedure|
        if service_names.include?(procedure.service_name)
          core_name = Organization.find(core_id).name
          procedure.update_attributes(sparc_core_name: core_name, sparc_core_id: core_id)
        end
      end
    end
  end

  def change_organizations(deleted_organization, service_names)
    old_procedures = Procedure.where(sparc_core_name: "#{deleted_organization}")

    if old_procedures.empty?
      puts "It appears that there are no procedures for this core. Exiting task..."
    else
      proceed = prompt "Found procedures, would you like to proceed? (y/n): "
      if proceed == 'y'
        fix_procedures(service_names, old_procedures)
      else
        puts "Exiting task..."
      end
    end
  end

  puts "This task will move procedures from a deleted core to a new core(s)."
  puts ""
  puts ""
  deleted_organization = prompt "Enter the exact name of the core that was deleted: "

  new_core_ids = []

  core_count = (prompt "Enter the number of cores it was split into: ").to_i
  # core_count.to_i
  core_count.times do
    new_core_ids << (prompt "Enter the core's id: ").to_i
  end

  # create a hash of service names that are under the new core(s) so we can place the procedures
  # under the correct one(s)
  service_names = create_core_hash(new_core_ids)

  change_organizations(deleted_organization, service_names)
end