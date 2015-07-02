class ChangeQuantityRequestedInLineItemsToDecimal < ActiveRecord::Migration
  def up
    change_column :line_items, :quantity_requested, :decimal, precision: 10, scale: 2, default: 0
  end

  def down
    change_column :line_items, :quantity_requested, :integer, default: 0
  end
end
