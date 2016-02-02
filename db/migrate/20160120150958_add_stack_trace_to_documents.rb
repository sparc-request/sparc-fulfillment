class AddStackTraceToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :stack_trace, :text, :null => true
  end
end
