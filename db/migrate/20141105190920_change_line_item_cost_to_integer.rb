class ChangeLineItemCostToInteger < ActiveRecord::Migration
  def change
    change_column :line_items, :cost, :integer
  end
end
