class AddServiceDataToFulfillment < ActiveRecord::Migration
  def change
    add_column :fulfillments, :service_id, :integer
    add_index :fulfillments, :service_id
    add_column :fulfillments, :service_name, :string
    add_column :fulfillments, :service_cost, :integer
  end
end
