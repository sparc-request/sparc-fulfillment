class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :sparc_id
      t.references :arm, index: true
      t.references :service, index: true
      t.integer :quantity

      t.timestamps
    end
  end
end
