class AddReportTypeToDocuments < ActiveRecord::Migration
  def up
    add_column :documents, :report_type, :string

    Document.find_each do |d|
      d.update_attributes(report_type: d.title.titleize.delete(" ").underscore) unless d.title.blank?
    end
  end

  def down
    remove_column :documents, :report_type, :string
  end
end
