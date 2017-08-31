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
  desc "Revert procedures from CSV"
  task revert_procedures_from_csv: :environment do
    #### csv location tmp/reverted_procedures.csv
    #### procedure id,old service id,new service id,old service name,new service name

    CSV.open("tmp/updated_procedures.csv", "wb") do |csv|
      csv << ['action', 'procedure id', 'old service id', 'new service id', 'old service name', 'new service name']

      CSV.foreach("tmp/reverted_procedures.csv", headers: true) do |row|
        procedure = Procedure.find row['procedure id']
        old_service_id = procedure.service_id
        old_service_name = procedure.service_name
        if procedure.update_attributes(service_id: row['new service id'], service_name: row['new service name'])
          csv << ['Success', procedure.id, old_service_id, procedure.service_id, old_service_name, procedure.service_name]
        else
          csv << ['Failed', procedure.id]
        end
      end
    end
  end
end
