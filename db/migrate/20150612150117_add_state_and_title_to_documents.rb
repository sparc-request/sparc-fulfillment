class AddStateAndTitleToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :title, :string
    add_column :documents, :state, :string, default: "Pending"
  end
end
