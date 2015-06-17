class AddDownloadedAtToDocuments < ActiveRecord::Migration

  # Records the first time the document was downloaded
  def change
    add_column :documents, :last_accessed_at, :timestamp
  end
end
