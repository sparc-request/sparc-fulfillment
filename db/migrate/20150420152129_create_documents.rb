class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.integer :documentable_id
      t.string :documentable_type
      t.datetime :deleted_at
      t.timestamps
    end
    add_attachment :documents, :doc
    add_index "documents", ["documentable_id", "documentable_type"], name: "index_documents_on_documentable_id_and_documentable_type", using: :btree
  end
end
