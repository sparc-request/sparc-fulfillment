class SlcAddLineItemAttributes < ActiveRecord::Migration
  def change
    add_column :line_items, :quantity_requested, :integer, default: 0
    add_column :line_items, :quantity_type, :string
    add_column :line_items, :started_at, :datetime
    add_column :line_items, :protocol_id, :integer
  end
end