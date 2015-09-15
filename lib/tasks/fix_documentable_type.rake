namespace :data do
  desc 'Fix documentable type on old documents to match current systems'
  task fix_documentable_type: :environment do
    documents = Document.all
    @count = 0
    find_and_fix_documents_in(documents)
    puts "Found and fixed #{@count} documents."
  end

  def find_and_fix_documents_in list
    if list.length == 1
      document = list[0]
      if ["project_summary_report", "auditing_report", "billing_report"].include? document.report_type
        (document.documentable_type == "Identity") ? nil : document.update_attributes(documentable_type: "Identity")
        @count += 0
      end
    else
      if list.length % 2 == 0
        bot = list[0..(list.length() - 1) / 2]
        top = list[list.length / 2, list.length - 1]
      else
        bot = list[0..(list.length() - 1) / 2 - 1]
        top = list[list.length / 2, list.length - 1]
      end
      find_and_fix_documents_in(bot)
      find_and_fix_documents_in(top)
    end
  end
end
