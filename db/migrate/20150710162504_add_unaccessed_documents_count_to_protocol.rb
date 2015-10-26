class AddUnaccessedDocumentsCountToProtocol < ActiveRecord::Migration
  def change
    add_column :protocols, :unaccessed_documents_count, :integer, default: 0
  end
end
