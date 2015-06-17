class AddFileTypeToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :content_type, :string
  end
end
