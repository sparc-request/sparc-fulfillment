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

require 'csv'

namespace :data do
  desc "Generate CSV of out of sync visit groups"
  task osvg_report: :environment do
    out_of_sync_count = 0
    out_of_sync_arms = []

    Arm.all.each do |arm|
      next if arm.protocol.sub_service_request.blank? or arm.protocol.status == 'complete'

      begin
        visit_groups = arm.visit_groups

        visit_groups = visit_groups.sort_by{|x| x.day.to_i}

        visit_groups.each_cons(2) do |a, b|
          comp = b.position <=> a.position
          if comp <= 0
            out_of_sync_count += 1
            out_of_sync_arms << arm.id
            break 
          end
        end

      rescue Exception => e
        puts "#"*100
        puts "Error checking Arm #{arm.id}, message: #{e.message}"
        puts "#"*100
        puts ""
      end
    end

    puts "Out of sync count = #{out_of_sync_count}"
    puts "Out of sync arms = #{out_of_sync_arms.inspect}"

    CSV.open("/tmp/out_of_sync_arms.csv", "w+") do |csv|
      csv << ["protocol_id", "id", "sparc_id", "arm_id", "position", "name", "day", "window_before", "window_after", "created_at", "updated_at", "deleted_at"]
      Arm.where(:id => out_of_sync_arms).each do |arm|
        visit_groups = arm.visit_groups.sort_by{|x| x.day.to_i}
        visit_groups.each do |visit_group|
          data = [visit_group.arm.protocol.srid]
          data += visit_group.attributes.values
          csv << data
        end
        csv << [""]
      end
    end
  end
end
