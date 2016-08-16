namespace :data do
  desc "Delete reports (associated with Identities) that are in the Processing state; use YYYY-MM-DD format for before_or_on_date parameter."

  task :destroy_processing_reports, [:before_or_on_date] => :environment do |t, args|
    ActiveRecord::Base.transaction do
      Document.where("DATE(created_at) <= ? AND documentable_type = 'Identity' AND state = 'Processing'", args[:before_or_on_date] || Time.now).destroy_all
    end
  end
end
