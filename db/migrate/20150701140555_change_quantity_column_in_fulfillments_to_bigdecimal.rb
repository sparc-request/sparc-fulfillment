class ChangeQuantityColumnInFulfillmentsToBigdecimal < ActiveRecord::Migration
  def up
    change_column :fulfillments, :quantity, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :fulfillments, :quantity, :integer
  end
end
