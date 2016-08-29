namespace :data do
  desc "Delete reports that are in the Processing state; rake data:destroy_processing_reports[YYYY-MM-DD]"

  task :destroy_processing_reports, [:before_or_on_date] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      Document.where("DATE(created_at) <= ? AND state = 'Processing'", args[:before_or_on_date] || Time.now).destroy_all
    end
  end
end
