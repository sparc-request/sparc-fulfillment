class RemovingQuantityFromLineItems < ActiveRecord::Migration
  def change
    remove_column :line_items, :quantity
  end
end
