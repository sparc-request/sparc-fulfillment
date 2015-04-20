class CreateFulfillments < ActiveRecord::Migration
  def change
    create_table :fulfillments do |t|
      t.integer :line_item_id
      t.datetime :fulfilled_at
      t.integer :quantity
      t.integer :performed_by
      t.integer :created_by
      t.timestamps
      t.timestamp :deleted_at
    end
  end
end
