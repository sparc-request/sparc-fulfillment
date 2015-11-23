namespace :data do
  desc 'Fix out of order visits groups'
  task fix_visit_group_positions: :environment do
    class VisitGroup < ActiveRecord::Base; end

    count = `wc -l /tmp/data.csv`.split.first

    bar = ProgressBar.new(count)

    CSV.foreach '/tmp/data.csv', headers: true do |row|
      next if row['id'].blank?

      vg = VisitGroup.find row['id']

      vg.update_attributes position: row['position'], day: row['day']

      bar.increment! rescue nil
    end
  end
end
