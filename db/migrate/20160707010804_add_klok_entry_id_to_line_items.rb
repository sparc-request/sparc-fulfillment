class AddKlokEntryIdToLineItems < ActiveRecord::Migration
  def change
    add_column :fulfillments, :klok_entry_id, :integer
    add_index  :fulfillments, :klok_entry_id
  end
end
