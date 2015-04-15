class CreateFulfillments < ActiveRecord::Migration
  def change
    create_table :fulfillments do |t|
      t.belongs_to :line_item
      t.belongs_to :user
      t.belongs_to :service_component
      t.integer :quantity
      t.string :tracking_type
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
