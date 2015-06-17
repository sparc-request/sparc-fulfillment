class RemovePaperclipColumns < ActiveRecord::Migration
  def change
    remove_column :documents, :doc_file_name
    remove_column :documents, :doc_content_type
    remove_column :documents, :doc_file_size
    remove_column :documents, :doc_updated_at
  end
end
