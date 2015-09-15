namespace :data do
  desc 'Fix documentable type on old documents to match current systems'
  task fix_documentable_type: :environment do
    count = 0
    Document.all.each do |doc|
      if ["project_summary_report", "auditing_report", "billing_report"].include? doc.report_type
        if doc.documentable_type == "Identity"
          doc.update_attributes(documentable_type: "Identity")
        end
        count += 1
      end
    end
    puts "Found and fixed #{count} documents."
  end
end
