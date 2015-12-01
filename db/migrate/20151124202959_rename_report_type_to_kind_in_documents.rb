class RenameReportTypeToKindInDocuments < ActiveRecord::Migration
  def change
    rename_column :documents, :report_type, :kind
  end
end
