class AddCostAndNameToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :name, :string
    add_column :line_items, :cost, :decimal
  end
end
