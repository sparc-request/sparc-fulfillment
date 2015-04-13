class AddQuanityOtfCostToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :quantity, :integer
    add_column :line_items, :otf, :boolean
    add_column :line_items, :cost, :integer
    add_column :line_items, :protocol_id, :integer
  end
end
