namespace :data do
  desc 'Fix out of order visits groups'
  task fix_visit_group_positions: :environment do
    class VisitGroup < ActiveRecord::Base; end

    count = `wc -l /tmp/data.csv`.split.first

    bar = ProgressBar.new(count.to_i)

    CSV.foreach '/tmp/data.csv', headers: true do |row|
      bar.increment! rescue nil

      next if row['id'].blank?

      vg = VisitGroup.find row['id']

      vg.update_attributes position: row['position'], day: row['day']

    end
  end
end
