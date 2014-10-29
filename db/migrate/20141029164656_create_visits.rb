class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.integer :sparc_id
      t.references :line_item, index: true
      t.references :visit_group, index: true
      t.integer :research_billing_qty
      t.integer :insurance_billing_qty
      t.integer :effort_billing_qty

      t.timestamps
    end
  end
end
