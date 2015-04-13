class AddQuanityOtfCostToLineItem < ActiveRecord::Migration
  def change
    add_column :line_items, :quantity, :integer
    add_column :line_items, :otf, :boolean
    add_column :line_items, :cost, :double
  end
end
