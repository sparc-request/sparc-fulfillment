require 'csv'

namespace :data do
  desc "Generate CSV of out of sync visit groups"
  task osvg_report: :environment do
    out_of_sync_count = 0
    out_of_sync_arms = []

    Arm.all.each do |arm|
      next if arm.protocol.status == 'complete'

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
