class RemoveIrbDatesFromProtocols < ActiveRecord::Migration
  def change
    remove_column :protocols, :irb_approval_date, :timestamp
    remove_column :protocols, :irb_expiration_date, :timestamp
  end
end
