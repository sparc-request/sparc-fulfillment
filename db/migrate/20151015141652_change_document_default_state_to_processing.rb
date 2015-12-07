class ChangeDocumentDefaultStateToProcessing < ActiveRecord::Migration
  def change
    change_column :documents, :state, :string, default: "Processing"
  end
end
