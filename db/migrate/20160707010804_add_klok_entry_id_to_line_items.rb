class AddKlokEntryIdToLineItems < ActiveRecord::Migration
  def change
    add_column :fulfillments, :klok_entry_id, :integer
  end
end
