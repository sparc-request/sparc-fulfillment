class AddTimeTrackingIdToFulfillments < ActiveRecord::Migration[7.2]
  def change
    add_column :fulfillments, :time_tracking_id, :integer
    add_index :fulfillments, :time_tracking_id
  end
end
