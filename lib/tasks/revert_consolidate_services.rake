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

##Old script, broken by removal of octopus gem##

# namespace :data do
#   desc "Revert migrating services from 486,487 to 36"
#   task revert_consolidation: :environment do
#     class HistoricalProcedure < ActiveRecord::Base
#       self.table_name = 'procedures'
#       octopus_establish_connection(Octopus.config[:development][:recovery])
#       allow_shard :recovery
#     end

#     Procedure.transaction do
#       CSV.open("tmp/reverted_procedures.csv", "wb") do |csv|
#         csv << ['procedure id', 'old service id', 'new service id', 'old service name', 'new service name']
#         HistoricalProcedure.where(service_id: [486,487], status: ['unstarted', 'incomplete']).each do |hp|
#           proc = Procedure.where(id: hp.id).first

#           if proc
#             if hp.service_id != proc.service_id
#               csv << [proc.id, proc.service_id, hp.service_id, proc.service_name, hp.service_name]
#               proc.update_attributes(service_id: hp.service_id, service_name: hp.service_name)
#             end
#           end
#         end
#       end
#     end
#   end
# end
